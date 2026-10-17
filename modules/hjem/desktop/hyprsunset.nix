# hyprsunset configuration.
#
# Ported from home-manager's `modules/services/hyprsunset.nix` (BSD-3-Clause,
# (c) Home Manager contributors): same `toHyprconf` rendering and the same user
# service definition.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop.hyprland.sunset;
  hyprland = config.desktop.hyprland;

  hyprconf = import ../lib/hyprconf.nix { inherit lib; };

  importantPrefixes = [
    "$"
    "bezier"
    "curve"
    "name"
    "output"
    "source"
  ];

  # home-manager named generated config files `hm_<path with / stripped>`.
  confText = hyprconf.toHyprconf {
    attrs = cfg.settings;
    inherit (cfg) importantPrefixes;
  };
in
{
  options.desktop.hyprland.sunset = {
    enable = lib.mkEnableOption "hyprsunset";

    package = lib.mkPackageOption pkgs "hyprsunset" { };

    systemdTarget = lib.mkOption {
      type = lib.types.str;
      default = "graphical-session.target";
      defaultText = lib.literalExpression "\"graphical-session.target\"";
      description = "Systemd target to bind to.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra arguments passed to hyprsunset.";
    };

    importantPrefixes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = importantPrefixes;
      defaultText = lib.literalExpression "importantPrefixes";
      description = "List of attribute prefixes to source at the top of the config.";
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = { };
      description = "hyprsunset configuration written in Nix.";
    };
  };

  config = lib.mkIf (cfg.enable && hyprland.enable) {
    packages = [ cfg.package ];

    xdg.config.files."hypr/hyprsunset.conf" = lib.mkIf (cfg.settings != { }) {
      source = pkgs.writeText "hm_hyprhyprsunset.conf" confText;
    };

    systemd.services.hyprsunset = {
      wantedBy = [ cfg.systemdTarget ];
      description = "hyprsunset - Hyprland's blue-light filter";
      after = [ cfg.systemdTarget ];
      partOf = [ cfg.systemdTarget ];
      unitConfig = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        "X-Restart-Triggers" = lib.optional (
          cfg.settings != { }
        ) "${config.xdg.config.files."hypr/hyprsunset.conf".source}";
      };

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package}${
          lib.optionalString (cfg.extraArgs != [ ]) " ${lib.escapeShellArgs cfg.extraArgs}"
        }";
        Restart = "always";
        RestartSec = "10";
      };
    };
  };
}
