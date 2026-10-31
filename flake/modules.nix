{
  flake.modules = {
    nixos = {
      boot = ../modules/ff/default/system/boot.nix;
      displays = ../modules/ff/default/hardware/displays.nix;
      fuc = ../modules/ff/default/programs/fuc.nix;
      hyprland = ../modules/ff/windowManagers/hyprland/hyprland-nixos.nix;
      networking = ../modules/ff/default/services/networking.nix;
      paseo = ../modules/ff/default/services/paseo.nix;
      ssh = ../modules/ff/default/services/ssh-nixos.nix;
      sudo-rs = ../modules/ff/default/programs/sudo-rs.nix;
      sysctl = ../modules/ff/default/system/sysctl.nix;
      users = ../modules/ff/default/system/users.nix;
      uutils = ../modules/ff/default/programs/uutils.nix;
      uwsm-session = ../modules/ff/default/services/uwsm-session.nix;
    };

    hjem.default = ../modules/hjem;
  };

  # Compatibility alias for existing consumers.
  flake.nixosModules.ffDefault = ../modules/ff/nixosModules.nix;
}
