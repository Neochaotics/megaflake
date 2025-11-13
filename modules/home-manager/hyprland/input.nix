{
  config,
  lib,
  ...
}: {
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hyprland.enable {
    input = {
      # kb_model=pc104;
      # b_layout=us;
      # b_variant=;
      # b_options=;
      # kb_rules=;
      # b_file=;
      numlock_by_default = false;
      resolve_binds_by_sym = false;
      repeat_rate = 25;
      repeat_delay = 600;
      sensitivity = 0.0;
      accel_profile = "flat";
      force_no_accel = false; # Enabling this is not recommended due to potential cursor desynchronization.
      left_handed = false;
      # scroll_points=;
      # scroll_method=;
      scroll_button = "no_scroll";
      scroll_button_lock = 0;
      scroll_factor = 1.0;
      natural_scroll = false;
      follow_mouse = 1;
      mouse_refocus = true;
      float_switch_override_focus = 1;
      special_fallthrough = false;
      off_window_axis_events = 1;
      emulate_discrete_scroll = 1;
      touchpad = {
        disable_while_typing = true;
        natural_scroll = true;
        tap_button_map = "lmr";
      };
    };

    binds = {
      pass_mouse_when_bound = false;
      scroll_event_delay = 300;
      workspace_back_and_forth = false;
      allow_workspace_cycles = false;
      workspace_center_on = 0;
      focus_preferred_method = 0;
      ignore_group_lock = false;
      movefocus_cycles_fullscreen = true;
      disable_keybind_grabbing = false;
      window_direction_monitor_fallback = true;
    };

    cursor = {
      sync_gsettings_theme = true;
      no_hardware_cursors = 1;
      no_break_fs_vrr = 2;
      min_refresh_rate = 30;
      hotspot_padding = 3;
      inactive_timeout = 180;
      no_warps = false;
      persistent_warps = false;
      warp_on_change_workspace = 2;
      default_monitor = "DP-2";
      zoom_factor = 1.0;
      zoom_rigid = false;
      enable_hyprcursor = true;
      hide_on_key_press = true;
      hide_on_touch = true;
    };
  };
  home.pointerCursor.hyprcursor.enable = true;
}
