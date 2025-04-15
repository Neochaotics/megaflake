{ config, lib, ... }:
{
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hyprland.enable {
    monitor = [
      "DP-2, 2560x1440@120, 0x0, 1"
      "DP-1,1920x1080@60, auto-right, 1, transform, 3"
      "HDMI-A-1, 1920x1080@60, auto-up, 1"
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
      "9, monitor:HDMI-A-1"
      "10, monitor:HDMI-A-1"
      "name:G, on-created-empty:uwsm app -- steam.desktop:Library, monitor:DP-2"
    ];
  };
}
