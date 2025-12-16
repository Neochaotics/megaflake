{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.qm.desktop.hypr.land.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "foot";
    };
    xdg.configFile = {
      "env" = {
        target = "uwsm/env";
        text = ''
          export XDG_SESSION_TYPE=wayland
          export GDK_BACKEND=wayland,x11
          export CLUTTER_BACKEND=wayland
          export QT_QPA_PLATFORM=wayland;xcb
          export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          export SDL_VIDEODRIVER=x11
          export QT_AUTO_SCREEN_SCALE_FACTOR=1
          export QT_SCALE_FACTOR=1
          export GDK_SCALE=1
          export MOZ_ENABLE_WAYLAND=1
          export ELECTRON_OZONE_PLATFORM_HINT=wayland
          export NIXOS_OZONE_WL=1
        '';
      };
      "env-hyprland" = {
        target = "uwsm/env-hyprland";
        text = ''
          export HYPRCURSOR_THEME=Bibata-Modern-Amber
        ''; # "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
      };
    };
  };
}
