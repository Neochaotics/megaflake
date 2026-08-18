_: {
  flake.modules.nixos.quinno-hyprland = _: {
    hjem.users.quinno.programs.hyprland = {
      enable = true;
      settings = {
        general = {
          border_size = 4;
          gaps_in = 5;
          gaps_out = 12;
          gaps_workspaces = 0;
          layout = "dwindle";
          no_focus_fallback = false;
          resize_on_border = true;
          extend_border_grab_area = 12;
          hover_icon_on_border = true;
          allow_tearing = true;
          resize_corner = 0;
          snap = {
            enabled = true;
            window_gap = 10;
            monitor_gap = 10;
            border_overlap = false;
          };
        };
        group = {
          auto_group = true;
          insert_after_current = true;
          focus_removed_window = true;
          drag_into_group = 2;
          merge_groups_on_drag = true;
          merge_groups_on_groupbar = true;
          merge_floated_into_tiled_on_groupbar = true;
          group_on_movetoworkspace = false;
          groupbar = {
            enabled = true;
            font_size = 12;
            gradients = true;
            height = 16;
            indicator_height = 4;
            stacked = false;
            priority = 3;
            render_titles = true;
            scrolling = true;
            rounding = 0;
            gradient_rounding = 0;
            text_padding = 4;
          };
        };
        decoration = {
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
        animations = {
          enabled = true;
          workspace_wraparound = true;
        };
        bezier = [
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
        animation = [
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
        input = {
          numlock_by_default = false;
          resolve_binds_by_sym = false;
          repeat_rate = 25;
          repeat_delay = 600;
          sensitivity = 0.0;
          accel_profile = "flat";
          force_no_accel = false;
          left_handed = false;
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
          no_update_news = true;
          no_donation_nag = true;
        };
        render.new_render_scheduling = true;
        debug.enable_stdout_logs = false;
        bind = [
          "SUPER, R, exec, pkill fuzzel || uwsm app -- fuzzel"
          "SUPER, B, exec, uwsm app -- firefox"
          "SUPER ALT, B, exec, uwsm app -- chromium"
          "SUPER, Return, exec, uwsm app -- foot"
          "SUPER, V, exec, uwsm app -- pavucontrol"
          "SUPER, D, exec, uwsm app -- legcord"
          "SUPER CTRL ALT, P, exec, systemctl poweroff"
          "SUPER CTRL ALT, R, exec, systemctl reboot"
          "SUPER CTRL ALT, L, exec, hyprlock"
          "SUPER CTRL ALT, K, exec, uwsm stop"
          "SUPER, W, killactive"
          "SUPER, S, layoutmsg, togglesplit"
          "SUPER, T, togglegroup"
          "SUPER, F9, pseudo"
          "SUPER, F10, togglefloating"
          "SUPER, F11, fullscreen, 0"
          "SUPER, F12, pin"
          "SUPER, N, exec, hyprctl hyprsunset gamma 100 && hyprctl hyprsunset identity"
          "SUPER SHIFT, N, exec, hyprctl hyprsunset gamma 60 && hyprctl hyprsunset temperature 3700"
          "SUPER, H, movefocus, l"
          "SUPER, L, movefocus, r"
          "SUPER, K, movefocus, u"
          "SUPER, J, movefocus, d"
          "SUPER SHIFT, H, movewindow, l"
          "SUPER SHIFT, L, movewindow, r"
          "SUPER SHIFT, K, movewindow, u"
          "SUPER SHIFT, J, movewindow, d"
          "SUPER ALT, H, resizeactive, -50 0"
          "SUPER ALT, L, resizeactive, 50 0"
          "SUPER ALT, K, resizeactive, 0 -50"
          "SUPER ALT, J, resizeactive, 0 50"
          "SUPER, 1, workspace, 1"
          "SUPER, 2, workspace, 2"
          "SUPER, 3, workspace, 3"
          "SUPER, 4, workspace, 4"
          "SUPER, 5, workspace, 9"
          "SUPER ALT, 1, workspace, 5"
          "SUPER ALT, 2, workspace, 6"
          "SUPER ALT, 3, workspace, 7"
          "SUPER ALT, 4, workspace, 8"
          "SUPER ALT, 5, workspace, 10"
          "SUPER SHIFT, 1, movetoworkspace, 1"
          "SUPER SHIFT, 2, movetoworkspace, 2"
          "SUPER SHIFT, 3, movetoworkspace, 3"
          "SUPER SHIFT, 4, movetoworkspace, 4"
          "SUPER SHIFT, 5, movetoworkspace, 9"
          "SUPER SHIFT ALT, 1, movetoworkspace, 5"
          "SUPER SHIFT ALT, 2, movetoworkspace, 6"
          "SUPER SHIFT ALT, 3, movetoworkspace, 7"
          "SUPER SHIFT ALT, 4, movetoworkspace, 8"
          "SUPER SHIFT ALT, 5, movetoworkspace, 10"
          "Super, BracketLeft, workspace, -1"
          "Super, BracketRight, workspace, +1"
          "SUPER, G, workspace, name:G"
          "SUPER SHIFT, G, movetoworkspace, name:G"
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          "ALT, XF86AudioRaiseVolume, exec, playerctl volume 0.1+"
          "ALT, XF86AudioLowerVolume, exec, playerctl volume 0.1-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPause, exec, playerctl pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioMicMute, exec, wpctl set-source-mute @DEFAULT_SOURCE@ toggle"
          "SUPER, PRINT, exec, hyprshot -m window"
          ", PRINT, exec, hyprshot -m output"
          "SUPER SHIFT, PRINT, exec, hyprshot -m region"
        ];
        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];
        windowrule = [
          "float on, match:title ^(Volume Control)$"
          "size 1050 500, match:title ^(Volume Control)$"
          "move 18 60, match:title ^(Volume Control)$"
          "pin on, match:title ^(Volume Control)$"
          "border_color rgb(1d2021), match:xwayland 1"
          "idle_inhibit fullscreen, match:class ^steam_app_.*"
          "idle_inhibit fullscreen, match:title ^(.*\\[Playing\\].*)$"
          "idle_inhibit fullscreen, match:class ^(com.stremio.stremio)$"
          "idle_inhibit focus, match:class ^(tidal-hifi)$"
          "fullscreen 1, match:class ^(steam_app_.*)"
          "immediate 1, match:class ^(steam_app_.*)"
          "no_blur 1, match:class ^(steam_app_.*)"
          "no_anim 1, match:class ^(steam_app_.*)"
        ];
      };
      extraConfig = ''
        env = XDG_SESSION_TYPE,wayland
        env = XDG_CURRENT_DESKTOP,Hyprland
        env = GDK_BACKEND,wayland,x11
        env = CLUTTER_BACKEND,wayland
        env = QT_QPA_PLATFORM,wayland;xcb
        env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
        env = RADV_TEX_ANISO,16
        env = QT_AUTO_SCREEN_SCALE_FACTOR,1
        env = QT_SCALE_FACTOR,1
        env = GDK_SCALE,1
        env = MOZ_ENABLE_WAYLAND,1
        env = ELECTRON_OZONE_PLATFORM_HINT,wayland
        env = NIXOS_OZONE_WL,1
        env = HYPRCURSOR_THEME,Bibata-Modern-Amber
        exec-once = uwsm app -- foot
        exec-once = uwsm app -- waybar
      '';
    };
  };
}
