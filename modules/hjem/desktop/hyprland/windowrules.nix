{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.desktop.hyprland.enable {
    desktop.hyprland.settings.windowrule = [
      "float on, match:title ^(Volume Control)$"
      "size 1050 500, match:title ^(Volume Control)$"
      "move 18 60, match:title ^(Volume Control)$"
      "pin on, match:title ^(Volume Control)$"
      "border_color rgb(1d2021), match:xwayland 1"
      "idle_inhibit fullscreen, match:class ^steam_app_.*"
      "idle_inhibit fullscreen, match:title ^(.*\\[Playing\\].*)$"
      "idle_inhibit fullscreen, match:class ^(com.stremio.stremio)$"
      "idle_inhibit focus, match:class ^(tidal-hifi)$"
      "fullscreen 1, match:class ^(steam_app_.*)"
      "immediate 1, match:class ^(steam_app_.*)"
      "no_blur 1, match:class ^(steam_app_.*)"
      "no_anim 1, match:class ^(steam_app_.*)"
    ];
  };
}
