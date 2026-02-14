{
  config,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hypr.land.enable {
    windowrule = [
      "match:title ^(Volume Control)$, float on, size 1050 500, move 18 60, pin on"
    ];

    windowrulev2 = [
      "match:xwayland 1, border_color rgb(1d2021)"
      "match:class ^steam_app_.*, idle_inhibit fullscreen"
      "match:title ^(.*\\[Playing\\].*)$, idle_inhibit fullscreen"
      "match:class ^(com.stremio.stremio)$, idle_inhibit fullscreen"
      "match:class ^(tidal-hifi)$, idle_inhibit focus"
    ];
  };
}
