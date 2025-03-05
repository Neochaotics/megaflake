{
  lib,
  inputs,
  config,
  pkgs,
  self,
  ...
}:
let
  username = "quinno";
in
{
  imports = [
    inputs.ff.nixosModules.freedpomFlake
    inputs.qm.nixosModules.qModule
    inputs.disko.nixosModules.disko
    ./disks.nix
    ./hardware.nix
    ../../home
    #(import ../../home/quinno {
    #  userName = username;
    #  inherit lib;
    #})
  ];
  age = {
    secrets.crypt = {
      generator.script = "passphrase";
    };
    rekey = {
      masterIdentities = [ "/persist/age.key" ];
      localStorageDir = "${self}" + "/secrets/rekeyed/${config.networking.hostName}";
      generatedSecretsDir = "${self}" + "/secrets/generated/${config.networking.hostName}";
      storageMode = "local";
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_cachyos-server;
    zfs.package = pkgs.zfs_cachyos;
  };

  users = {
    users.${username} = {
      #hashedPasswordFile = config.sops.secrets.qpassword.path;
      initialPassword = "password";
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
      extraGroups =
        [ "wheel" ]
        ++ lib.optional config.security.rtkit.enable "rtkit"
        ++ lib.optional config.services.pipewire.enable "audio";
    };
    mutableUsers = true;
  };

  services.getty.autologinUser = "${username}";

  # System Configuration
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";

  services.tailscale.enable = true;

  ff = {
    common.enable = true;
    security = {
      sudo-rs.enable = true;
    };
    services = {
      ananicy.enable = true;
      pipewire.enable = true;
      openssh.enable = true;
    };
    system = {
      persistence.enable = true;
      nix.enable = true;
      sysctl = {
        cachyos = true;
        mineral = false;
      };
      systemd-boot.enable = true;
    };
  };

  # Custom Module Configuration
  qm = {
    programs = {
      hyprland.enable = true;
      steam.enable = true;
      nvf.enable = true;
    };
    stylix.enable = true;
    wireguard.enable = false;
  };
}
