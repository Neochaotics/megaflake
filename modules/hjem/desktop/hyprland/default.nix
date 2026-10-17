# Hyprland configuration (Lua).
#
# Hyprland 0.56 reads `hypr/hyprland.lua`. The body is rendered with the local
# Lua generator (see `lua.nix`) from the same `desktop.hyprland.settings`
# attrset the submodules populate, so Nix stays the single source of truth.
# `uwsm/env*` are written verbatim.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop.hyprland;

  lua = import ./lua.nix { inherit lib; };
in
{
  imports = [
    ./appearance.nix
    ./general.nix
    ./input.nix
    ./misc.nix
    ./bindings.nix
    ./windowrules.nix
    ./env.nix
    ./monitors.nix
  ];

  options.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland configuration";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.hyprland;
      defaultText = lib.literalExpression "pkgs.hyprland";
      description = "The Hyprland compositor package to install.";
    };

    portalPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "The `xdg-desktop-portal-hyprland` package to install.";
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
      description = "Hyprland configuration written in Nix.";
    };

    xwayland = {
      enable = lib.mkEnableOption "XWayland" // {
        default = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [
      cfg.package
    ]
    ++ lib.optional cfg.xwayland.enable pkgs.xwayland
    ++ lib.optional (cfg.portalPackage != null) cfg.portalPackage
    # xdg-desktop-portal is pulled in by the NixOS-side portal module, but
    # home-manager linked it into the user profile too.
    # home-manager also linked the desktop portal into the user profile.
    ++ [ pkgs.hyprpolkitagent ]
    ++ lib.optional (cfg.portalPackage != null) pkgs.xdg-desktop-portal;

    xdg.config.files."hypr/hyprland.lua".text = lib.mkIf (cfg.settings != { }) (
      lua.render cfg.settings
    );

    # uwsm sources these for the session environment.
    xdg.config.files = {
      "uwsm/env".text = cfg.sessionEnvironment;
      "uwsm/env-hyprland".text = cfg.hyprlandEnvironment;
    };
  };
}
