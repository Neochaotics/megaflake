# Hyprland configuration.
#
# The `hypr/hyprland.conf` body is rendered with home-manager's exact
# `toHyprconf` generator (see `lib/hyprconf.nix`), and `uwsm/env*` are written
# verbatim the same way home-manager's `xdg.configFile` targets did.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop.hyprland;

  inherit (lib) mkIf optionalString;

  hyprconf = import ../../lib/hyprconf.nix { inherit lib; };

  # home-manager's default, so that top-level settings such as `bezier` are
  # emitted first in the same order.
  importantPrefixes = [
    "$"
    "bezier"
    "curve"
    "name"
    "output"
    "source"
  ];
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

    importantPrefixes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = importantPrefixes;
      defaultText = lib.literalExpression "importantPrefixes";
      description = ''
        List of prefix of attributes to source at the top of the config.
      '';
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra configuration appended verbatim to {file}`hyprland.conf`.";
    };

    xwayland = {
      enable = lib.mkEnableOption "XWayland" // {
        default = true;
      };
    };

    # `hyprland-session.target` integration; home-manager had it off for this
    # host because uwsm owns the session lifecycle.
    systemd = {
      enable = lib.mkEnableOption "hyprland-session.target integration" // {
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
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

    xdg.config.files."hypr/hyprland.conf".text =
      optionalString (cfg.settings != { }) (
        hyprconf.toHyprconf {
          attrs = cfg.settings;
          inherit importantPrefixes;
        }
      )
      + optionalString (cfg.extraConfig != "") cfg.extraConfig;

    # home-manager wrote these through `xdg.configFile` with an explicit
    # `target`; hjem spells the same thing as a nested file name.
    xdg.config.files = {
      "uwsm/env".text = cfg.sessionEnvironment;
      "uwsm/env-hyprland".text = cfg.hyprlandEnvironment;
    };
  };
}
