{ config, lib, ... }:
{
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hyprland.enable {
    monitor = [
      "DP-2, 2560x1440@120, auto, 1"
      "DP-1,1920x1080@60, auto-right, 1, transform, 3"
      "DP-5, 1920x1080@60, auto-up, 1"
    ];

    workspace = [
      "1, monitor:DP-2"
      "2, monitor:DP-2"
      "3, monitor:DP-2"
      "4, monitor:DP-2"
      "5, monitor:DP-1"
      "6, monitor:DP-1"
      "7, monitor:DP-1"
      "8, monitor:DP-1"
      "9, monitor:DP-5"
      "10, monitor:DP-5"
      "name:G, on-created-empty:uwsm app -- steam.desktop:Library, monitor:DP-2"
    ];
  };
}
