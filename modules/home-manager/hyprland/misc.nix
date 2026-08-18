{
  config,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hypr.land.enable {
    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      force_default_wallpaper = 0;
      vrr = 2;
      mouse_move_enables_dpms = false;
      key_press_enables_dpms = true;
      always_follow_on_dnd = true;
      layers_hog_keyboard_focus = false;
      animate_manual_resizes = false;
      animate_mouse_windowdragging = true;
      disable_autoreload = false;
      enable_swallow = true;
      swallow_regex = "foot";
      focus_on_activate = false;
      mouse_move_focuses_monitor = true;
      allow_session_lock_restore = false;
      close_special_on_empty = true;
      exit_window_retains_fullscreen = false;
      initial_workspace_tracking = 1;
      middle_click_paste = false;
      render_unfocused_fps = 15;
      disable_xdg_env_checks = false;
    };

    xwayland = {
      enabled = true;
      use_nearest_neighbor = true;
      force_zero_scaling = false;
    };

    ecosystem = {
      no_update_news = true; # https://hyprland.org/rss.xml
      no_donation_nag = true;
    };

    render = {
      new_render_scheduling = true;
    };

    debug = {
      enable_stdout_logs = false;
    };
  };
}
