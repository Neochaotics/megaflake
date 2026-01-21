{
  config,
  lib,
  ...
}:
{
  stylix.targets.hyprland.hyprpaper.enable = true;
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hypr.land.enable {
    decoration = {
      rounding = 6;
      rounding_power = 3.0;
      active_opacity = 0.9;
      inactive_opacity = 0.8;
      fullscreen_opacity = 1.0;
      dim_inactive = true;
      dim_strength = 0.1;
      dim_special = 0.0;
      dim_around = 0.3;
      border_part_of_window = false;
      # screen_shader = ;

      blur = {
        enabled = true;
        size = 9;
        passes = 3;
        ignore_opacity = false;
        new_optimizations = true;
        xray = false;
        noise = 0.003;
        contrast = 0.6;
        brightness = 0.6;
        vibrancy = 0.09;
        vibrancy_darkness = 0.09;
        special = false;
        popups = false;
        popups_ignorealpha = 0.2;
      };

      shadow = {
        enabled = true;
        range = 6;
        render_power = 1;
        sharp = false;
        ignore_window = true;
        offset = "0, 0";
        scale = 2.0;
      };
    };

    animations = {
      enabled = true;
      workspace_wraparound = true;
    };
    bezier = [
      "linear, 0, 0, 1, 1"
      "md3_standard, 0.2, 0, 0, 1"
      "md3_decel, 0.05, 0.7, 0.1, 1"
      "md3_accel, 0.3, 0, 0.8, 0.15"
      "overshot, 0.05, 0.9, 0.1, 1.1"
      "crazyshot, 0.1, 1.5, 0.76, 0.92"
      "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
      "menu_decel, 0.1, 1, 0, 1"
      "menu_accel, 0.38, 0.04, 1, 0.07"
      "easeInOutCirc, 0.85, 0, 0.15, 1"
      "easeOutCirc, 0, 0.55, 0.45, 1"
      "easeOutExpo, 0.16, 1, 0.3, 1"
      "softAcDecel, 0.26, 0.26, 0.15, 1"
      "md2, 0.4, 0, 0.2, 1" # use with .2s duration
    ];

    animation = [
      "windows, 1, 3, md3_decel, popin 60%"
      "windowsIn, 1, 3, md3_decel, popin 60%"
      "windowsOut, 1, 3, md3_accel, popin 60%"
      "border, 1, 10, default"
      "fade, 1, 3, md3_decel"
      "layersIn, 1, 3, menu_decel, slide"
      "layersOut, 1, 1.6, menu_accel"
      "fadeLayersIn, 1, 2, menu_decel"
      "fadeLayersOut, 1, 4.5, menu_accel"
      "workspaces, 1, 7, menu_decel, slide"
      "specialWorkspace, 1, 3, md3_decel, slidevert"
      "hyprfocusIn, 1, 1.7, md3_decel"
      "hyprfocusOut, 1, 1.7, md3_accel"
    ];
  };
}
