{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.freedpom.windowManagers.hyprland;
in
{
  options.freedpom.windowManagers.hyprland = {
    enable = lib.mkEnableOption "Hyprland user configuration";
  };
  config = lib.mkIf cfg.enable {

    home.pointerCursor.hyprcursor.enable = true;
    home.packages = with pkgs; [
      hyprpolkitagent
    ];

    wayland = {
      windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        systemd = {
          enable = false;
          enableXdgAutostart = false;
        };
        xwayland.enable = true;
      };
    };
  };
}
