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
    ../../modules/test/cespool.nix
  ];

  nixpkgs.overlays = [
    (_final: _prev: { stable = import inputs.nixpkgs-stable { system = "x86_64-linux"; }; })
  ];

  fonts.packages =
    with pkgs;
    [
      noto-fonts
      liberation_ttf
      dina-font
      proggyfonts

    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  users.users.${username} = {
    # User Configuration
    isNormalUser = true;
    description = formatUsername username;
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
    extraGroups =
      [ "wheel" ]
      ++ lib.optional config.security.rtkit.enable "rtkit"
      ++ lib.optional config.services.pipewire.enable "audio";
  };

  home-manager.users.${username} = import ./home.nix;

  # Service Configuration
  #
  boot.kernelPackages = pkgs.linuxPackages_zen;

  services.getty = {
    autologinUser = "${username}";
    autologinOnce = true;
  };

  # System Configuration
  system.stateVersion = "24.11";
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  ff = {
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
      nh.enable = true;
    };
    stylix.enable = true;
    wireguard.enable = false;
  };
}
