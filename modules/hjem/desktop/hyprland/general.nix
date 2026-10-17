{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.desktop.hyprland.enable {
    desktop.hyprland.settings.general = {
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

    desktop.hyprland.settings.group = {
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
  };
}
