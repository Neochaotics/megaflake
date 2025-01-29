{
  lib,
  inputs,
  config,
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
    inputs.disko.nixosModules.disko
    ./disk-primary.nix
    ./disk-secondary.nix
    ./hardware.nix
    ../../modules/nixos
  ];

  users.users.${username} = {
    # User Configuration
    isNormalUser = true;
    description = formatUsername username;
    extraGroups =
      [ "wheel" ]
      ++ lib.optional config.security.rtkit.enable "rtkit"
      ++ lib.optional config.services.pipewire.enable "audio";
  };

  home-manager.users.${username} = import ./home.nix;

  # Service Configuration

  services.getty = {
    autologinUser = username;
    autologinOnce = true;
  };

  # System Configuration
  system.stateVersion = "24.11";
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Custom Module Configuration
  cm.nixos = {
    packages = {
      hyprland.enable = true;
      sudo.enable = true;
      steam.enable = true;
      nvf.enable = true;
    };
    system = {
      home-manager.enable = true;
      nix.enable = true;
      sysctl.enable = true;
      systemd-boot.enable = true;
      sops.enable = false;
    };
    services = {
      ananicy.enable = true;
      pipewire.enable = true;
      openssh.enable = true;
    };
  };
}
