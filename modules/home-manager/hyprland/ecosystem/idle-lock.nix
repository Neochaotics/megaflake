{
  lib,
  config,
  ...
}:
let
  cfg = config.qm.desktop.hypr;
in
{
  options.qm.desktop.hypr.idle-lock = {
    enable = lib.mkEnableOption "Enable";
  };

  config = lib.mkIf (cfg.idle-lock.enable && cfg.land.enable) {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
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
      settings = {
        general = {
          hide_cursor = true;
          ignore_empty_input = true;
        };

      };
    };
  };
}
