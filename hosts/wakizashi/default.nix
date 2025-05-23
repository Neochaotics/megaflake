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
    (import ../../home/quinno {
      userName = username;
      inherit lib;
    })
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  age = {
    rekey = {
      masterIdentities = [ "/persist/age.key" ];
      localStorageDir = "${self}" + "/secrets/rekeyed/${config.networking.hostName}";
      generatedSecretsDir = "${self}" + "/secrets/generated/${config.networking.hostName}";
      storageMode = "local";
    };
  };

  users = {
    users.${username} = {
      initialPassword = "password";
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
      extraGroups =
        [ "wheel" ]
        ++ lib.optional config.security.rtkit.enable "rtkit"
        ++ lib.optional config.services.pipewire.enable "audio";
    };
    mutableUsers = lib.mkForce true;
  };

  services.getty.autologinUser = "${username}";

  # System Configuration
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";

  services.tailscale.enable = true;

  nixpkgs.config.allowUnfree = true;

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
      };
      systemd-boot.enable = true;
    };
  };

  # Custom Module Configuration
  qm = {
    programs = {
      hyprland.enable = true;
    };
    stylix.enable = true;
  };
}
