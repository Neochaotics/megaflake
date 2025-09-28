{
  config,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hyprland.enable {
    #monitor = [
    #  "DP-5, 1920x1080@60, auto-right, 1"
    #  "HDMI-A-1, 1920x1080@60, 0x0, 1"
    #];

    monitorv2 =
      lib.mapAttrsToList (name: cfg: ''
        {
          output = ${name}
          mode = ${toString cfg.resolution.width}x${toString cfg.resolution.height}@${toString cfg.framerate}
          position = ${cfg.position}
          scale = ${toString cfg.scale}
          transform = ${toString cfg.transform}${
          lib.optionalString (cfg ? mirror) "\n        mirror = ${cfg.mirror}"
        }${lib.optionalString (cfg ? bitdepth) "\n        bitdepth = ${toString cfg.bitdepth}"}
        }
      '')
      config.ff.hardware.videoPorts;

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
