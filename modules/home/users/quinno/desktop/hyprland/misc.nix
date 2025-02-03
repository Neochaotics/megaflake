{
  wayland.windowManager.hyprland.settings = {
    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
      # font_family = "Iosevka Nerd Font";
      # splash_font_family=;
      force_default_wallpaper = 0;
      vfr = true; # Heavily recommended to leave enabled to conserve resources.
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
      # swallow_exception_regex=;
      focus_on_activate = false;
      mouse_move_focuses_monitor = true;
      render_ahead_of_time = false; # [Warning: buggy] starts rendering before your monitor displays a frame in order to lower latency
      render_ahead_safezone = 1; # how many ms of safezone to add to rendering ahead of time. Recommended 1-2.
      allow_session_lock_restore = false;
      # background_color = "rgb(1F0F0B)"; Managed by stylix
      close_special_on_empty = true;
      new_window_takes_over_fullscreen = 2;
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

    opengl = {
      nvidia_anti_flicker = true; # On non-nvidia, this is ignored.
      force_introspection = 1; # Introspection is aimed at reducing GPU usage in certain cases, but might cause graphical glitches on nvidia.
    };

    ecosystem = {
      no_update_news = true; # https://hyprland.org/rss.xml
      no_donation_nag = true;
    };

    experimental = {
      wide_color_gamut = true;
      xx_color_management_v4 = true;
    };

    render = {
      explicit_sync = 2;
      explicit_sync_kms = 2;
      direct_scanout = true; # Enables direct scanout. Direct scanout attempts to reduce lag when there is only one fullscreen application on a screen (e.g. game). It is also recommended to set this to false if the fullscreen application shows graphical glitches.
    };

    debug = {
      enable_stdout_logs = false;
    };
  };
}
