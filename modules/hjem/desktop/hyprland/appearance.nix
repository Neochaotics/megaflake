{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.desktop.hyprland.enable {
    desktop.hyprland.settings.decoration = {
      rounding = 0;
      rounding_power = 2.0;
      active_opacity = 1.0;
      inactive_opacity = 0.95;
      fullscreen_opacity = 1.0;
      dim_inactive = true;
      dim_strength = 0.08;
      dim_special = 0.0;
      dim_around = 0.3;
      border_part_of_window = false;

      blur = {
        enabled = true;
        size = 4;
        passes = 2;
        ignore_opacity = false;
        new_optimizations = true;
        xray = false;
        noise = 0.002;
        contrast = 0.65;
        brightness = 0.7;
        vibrancy = 0.15;
        vibrancy_darkness = 0.1;
        special = false;
        popups = false;
        popups_ignorealpha = 0.2;
      };

      shadow = {
        enabled = true;
        range = 5;
        render_power = 3;
        sharp = false;
        offset = "0, 1";
        scale = 1.3;
      };
    };

    desktop.hyprland.settings.animations = {
      enabled = true;
      workspace_wraparound = true;
    };

    desktop.hyprland.settings.bezier = [
      "linear, 0, 0, 1, 1"
      "smoothOut, 0.36, 0, 0.66, -0.56"
      "smoothIn, 0.25, 1, 0.5, 1"
      "overshot, 0.05, 0.9, 0.1, 1.1"
      "crazyshot, 0.1, 1.5, 0.76, 0.92"
      "softAcDecel, 0.26, 0.26, 0.15, 1"
      "decel, 0.05, 0.9, 0.1, 1.0"
      "accel, 0.3, 0, 0.8, 0.15"
      "woodie, 0.05, 0.03, 0, 0.97"
      "expo, 0.01, 1.56, 0.06, 1"
    ];

    desktop.hyprland.settings.animation = [
      "windows, 1, 1.5, smoothOut, popin 70%"
      "windowsIn, 1, 1.5, smoothOut, popin 70%"
      "windowsOut, 1, 1.5, smoothIn, popin 50%"
      "border, 1, 8, default"
      "fade, 1, 1.5, decel"
      "fadeIn, 1, 1.5, decel"
      "fadeOut, 1, 1, accel"
      "fadeSwitch, 1, 1.5, decel"
      "layersIn, 1, 1.5, decel, slide"
      "layersOut, 1, 1, accel"
      "fadeLayersIn, 1, 1.5, decel"
      "fadeLayersOut, 1, 1, accel"
      "workspaces, 1, 2, decel, slide"
      "specialWorkspace, 1, 1.5, decel, slidevert"
    ];
  };
}
