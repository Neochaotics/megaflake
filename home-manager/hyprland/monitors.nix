{ config, lib, ... }:
{
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hyprland.enable {
    monitor = [
      "DP-5, 1920x1080@60, auto-right, 1.25"
      "HDMI-A-1, 1920x1080@60, 0x0, 1.25"
    ];

    workspace = [
      "1, monitor:HDMI-A-1"
      "2, monitor:HDMI-A-1"
      "3, monitor:HDMI-A-1"
      "4, monitor:HDMI-A-1"
      "5, monitor:DP-5"
      "6, monitor:DP-5"
      "7, monitor:DP-5"
      "8, monitor:DP-5"
      "name:G, monitor:HDMI-A-1"
    ];
  };
}
