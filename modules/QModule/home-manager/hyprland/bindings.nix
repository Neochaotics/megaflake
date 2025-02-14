{ config, lib, ... }:
{
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hyprland.enable {
    bind = [
      # Program Launching
      # --------------------
      "SUPER, R, exec, pkill fuzzle || uwsm app -- fuzzel"
      "SUPER, B, exec, uwsm app -- firefox.desktop:new-window"
      "SUPER SHIFT, B, exec, uwsm app -- firefox.desktop:new-private-window"
      "SUPER ALT, B, exec, uwsm app -- chromium.desktop"
      "SUPER ALT SHIFT, B, exec, uwsm app -- chromium.desktop:new-private-window"
      "SUPER, Return, exec, uwsm app -- foot.desktop"
      "SUPER, E, exec, uwsm app -- thunar.desktop"
      "SUPER, V, exec, uwsm app -- pavucontrol.desktop"
      "SUPER, D, exec, uwsm app -- legcord"

      # General Control
      # --------------------
      "SUPER CTRL ALT, P, exec, systemctl poweroff"
      "SUPER CTRL ALT, R, exec, systemctl reboot"
      "SUPER CTRL ALT, L, exec, hyprlock"
      "SUPER CTRL ALT, K, exec, uwsm stop"

      # General Control
      # --------------------
      "SUPER, W, killactive" # Close Active Window
      "SUPER, S, togglesplit" # Toggle Split Layout
      "SUPER, T, togglegroup" # Toggle Grouped Layout
      "SUPER, F9, pseudo" # Enable Pseudo Tiling
      "SUPER, F10, togglefloating" # Toggle Floating Window
      "SUPER, F11, fullscreen, 0" # Toggle Fullscreen
      "SUPER, F12, pin" # Pin window above others

      # Window Control
      # --------------------
      # ### Move focus #####
      "SUPER, H, movefocus, l"
      "SUPER, L, movefocus, r"
      "SUPER, K, movefocus, u"
      "SUPER, J, movefocus, d"

      # ### Swap windows #####
      "SUPER SHIFT, H, movewindow, l"
      "SUPER SHIFT, L, movewindow, r"
      "SUPER SHIFT, K, movewindow, u"
      "SUPER SHIFT, J, movewindow, d"

      # ### Window resize #####
      "SUPER ALT, H, resizeactive, -50 0"
      "SUPER ALT, L, resizeactive, 50 0"
      "SUPER ALT, K, resizeactive, 0 -50"
      "SUPER ALT, J, resizeactive, 0 50"

      # Switch workspaces with mainMod + [0-9]
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

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
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

      # Game
      "SUPER, G, workspace, name:G"
      "SUPER SHIFT, G, movetoworkspace, name:G"

      # Media Keys
      # --------------------
      ", XF86MonBrightnessUp, exec, $SCRIPTS_DIR/system-functions change_brightness -i -10"
      ", XF86MonBrightnessDown, exec, $SCRIPTS_DIR/system-functions change_brightness -i 10"
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

      # Screenshots
      # --------------------
      "SUPER, PRINT, exec, hyprshot -m window" # Screenshot a window
      ", PRINT, exec, hyprshot -m output" # Screenshot a monitor
      "SUPER SHIFT, PRINT, exec, hyprshot -m region" # Screenshot a region
    ];
    bindm = [
      # Move/resize windows with mainMod + LMB/RMB and dragging
      "SUPER, mouse:272, movewindow" # Move Window
      "SUPER, mouse:273, resizewindow" # Resize Window
    ];
  };
}
