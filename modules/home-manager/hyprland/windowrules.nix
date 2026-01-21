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
      "match:xwayland 1, bordercolor rgb (93000A)"
    ];
  };
}
