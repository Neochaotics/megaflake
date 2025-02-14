{ lib, config, ... }:
let
  cfg = config.qm.desktop.hyprland.enable.idlelock;
in
{
  options.qm.desktop.hyprland.idlelock = {
    enable = lib.mkEnableOption "Enable";
  };

  config = lib.mkIf (config.stylix.enable && cfg.enable) {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
    programs.hyprlock = {
      enable = true;
    };
  };
}
