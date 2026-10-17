# Hyprland session environment.
#
# Previously home-manager's `modules/home-manager/hyprland/env.nix`, which wrote
# `uwsm/env` and `uwsm/env-hyprland` as verbatim shell scripts.
{
  config,
  lib,
  ...
}:
let
  cfg = config.desktop.hyprland;

  sessionEnvironment = ''
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=Hyprland
    export GDK_BACKEND=wayland,x11
    export CLUTTER_BACKEND=wayland
    export QT_QPA_PLATFORM="wayland;xcb"
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export RADV_TEX_ANISO=16
    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export QT_SCALE_FACTOR=1
    export GDK_SCALE=1
    export MOZ_ENABLE_WAYLAND=1
    export ELECTRON_OZONE_PLATFORM_HINT=wayland
    export NIXOS_OZONE_WL=1
  '';

  hyprlandEnvironment = ''
    export HYPRCURSOR_THEME=Bibata-Modern-Amber
  ''; # "AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
in
{
  options.desktop.hyprland = {
    sessionEnvironment = lib.mkOption {
      type = lib.types.lines;
      default = sessionEnvironment;
      description = ''
        POSIX shell fragment sourced by uwsm to set the session variables.
        Written to {file}`$XDG_CONFIG_HOME/uwsm/env`.
      '';
    };

    hyprlandEnvironment = lib.mkOption {
      type = lib.types.lines;
      default = hyprlandEnvironment;
      description = ''
        POSIX shell fragment sourced by uwsm for compositor-specific variables.
        Written to {file}`$XDG_CONFIG_HOME/uwsm/env-hyprland`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    system.session.variables = {
      EDITOR = "nvim";
      TERMINAL = "foot";
      RADV_TEX_ANISO = "16";
    };
  };
}
