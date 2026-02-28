{
  config,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hypr.land.enable {
    windowrule = [
      "float on, match:title ^(Volume Control)$"
      "size 1050 500, match:title ^(Volume Control)$"
      "move 18 60, match:title ^(Volume Control)$"
      "pin on, match:title ^(Volume Control)$"
      "border_color rgb(1d2021), match:xwayland 1"
      "idle_inhibit fullscreen, match:class ^steam_app_.*"
      "idle_inhibit fullscreen, match:title ^(.*\\[Playing\\].*)$"
      "idle_inhibit fullscreen, match:class ^(com.stremio.stremio)$"
      "idle_inhibit focus, match:class ^(tidal-hifi)$"
    ];
  };
}
