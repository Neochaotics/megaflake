{ inputs, ... }:
{
  flake.modules.nixos = {
    profile-system-base = {
      imports = with inputs.self.modules.nixos; [
        boot
        fuc
        networking
        ssh
        sudo-rs
        sysctl
        users
        uutils
      ];
    };

    profile-desktop = {
      imports = with inputs.self.modules.nixos; [
        profile-system-base
        displays
        hyprland
        uwsm-session
      ];
    };

    ffDefault = {
      imports = with inputs.self.modules.nixos; [
        profile-desktop
        paseo
      ];
    };
  };
}
