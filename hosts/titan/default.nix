{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:
let
  username = "quinno";
  formatUsername =
    name:
    lib.strings.stringAsChars (
      c:
      if c == builtins.substring ((builtins.stringLength name) - 1) 1 name then
        " ${lib.strings.toUpper c}"
      else if c == (builtins.substring 0 1 name) then
        lib.strings.toUpper c
      else
        c
    ) name;
in
{
  imports = [
    inputs.ff.nixosModules.freedpomFlake
    inputs.qm.nixosModules.qModule
    inputs.disko.nixosModules.disko
    ./disk-primary.nix
    ./disk-secondary.nix
    ./hardware.nix
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age = {
      keyFile = "~/.config/sops/age/keys.txt";
    };
    secrets = {
      "qpassword" = {
        neededForUsers = true;
      };
    };
  };

  users = {
    users.${username} = {
      # User Configuration
      isNormalUser = true;
      description = formatUsername username;
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

  getty.autologinUser = "${username}";

  home-manager.users.${username} = import ./home.nix;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # System Configuration
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";

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
