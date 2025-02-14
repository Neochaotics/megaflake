{ config, lib, ... }:
{
  wayland.windowManager.hyprland.settings = lib.mkIf config.qm.desktop.hyprland {
    general = {
      border_size = 2;
      no_border_on_floating = false;
      gaps_in = 6;
      gaps_out = 12;
      gaps_workspaces = 0;
      # "col.active_border" = "rgb(D34000)"; Managed by stylix
      # "col.inactive_border" = "rgb(2C1B16)"; Managed by stylix
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
      # "col.border_active" = "rgb(782100)"; Managed by stylix
      # "col.border_inactive" = "rgb(2C1B16)"; Managed by stylix
      # "col.border_locked_active" = "rgb(782100)"; Managed by stylix
      groupbar = {
        enabled = true;
        # font_family=; # Defaults to misc:font_family
        font_size = 8;
        gradients = true;
        height = 14;
        stacked = false;
        priority = 3;
        render_titles = true;
        scrolling = true;
        # text_color = "rgb(FBDCD3)"; Managed by stylix
        # "col.active" = "rgba(00000000)"; Managed by stylix
        # "col.inactive" = "rgba(00000000)"; Managed by stylix
        # "col.locked_active" = "rgba(00000000)"; Managed by stylix
      };
    };
  };
}
