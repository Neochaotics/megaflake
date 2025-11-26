{
  config,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hyprland.enable {
    "plugin:hyprexpo" = {
      columns = 4;
      gap_size = 6;
      bg_col = config.wayland.windowManager.hyprland.settings.misc.background_color;
      workspace_method = "center current"; # [center/first] [workspace] e.g. first 1 or center m+1
      skip_empty = true;
      gesture_distance = 300;
    };
  };
}
