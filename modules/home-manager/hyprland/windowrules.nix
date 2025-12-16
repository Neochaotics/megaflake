{
  config,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hypr.land.enable {
    windowrule = [
      "float, title:^(Volume Control)$"
      "size 1050 500, title:^(Volume Control)$"
      "move 12 60, title:^(Volume Control)$"
      "pin, title:^(Volume Control)$"
      "monitor $M2, title:^(Volume Control)$"
      "opacity 0.85 override, title:^(Volume Control)$"
      "noborder, title:^(Volume Control)$"
    ];

    windowrulev2 = [
      "bordercolor rgb (93000A),xwayland:1" # color = errorContainer

      "workspace $media_workspace, class:^(.*stremio.*)$"
      "workspace $media_workspace, class:^(.*spotify.*)$"

      "workspace $comm_workspace, class:^(.*legcord.*)$"
    ];
  };
}
