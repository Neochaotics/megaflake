# hypridle configuration and user service.
#
# Ported from home-manager's `modules/services/hypridle.nix` (BSD-3-Clause, (c)
# Home Manager contributors). Both the config file and the service are rendered
# here rather than by hjem-rum so that the store path of `hypr/hypridle.conf`
# keeps home-manager's `hm_*` naming, which the unit embeds.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop.hypridle;
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

  # home-manager named generated config files `hm_<path with / stripped>`, and
  # the service embeds that store path, so keep the convention.
  confText = hyprconf.toHyprconf {
    attrs = cfg.settings;
    inherit (cfg) importantPrefixes;
  };
  confPath = "${pkgs.writeText "hm_hyprhypridle.conf" confText}";
in
{
  options.desktop.hypridle = {
    enable = lib.mkEnableOption "hypridle";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.hypridle;
      defaultText = lib.literalExpression "pkgs.hypridle";
      description = "The hypridle package to run.";
    };

    systemdTarget = lib.mkOption {
      type = lib.types.str;
      default = "graphical-session.target";
      defaultText = lib.literalExpression "\"graphical-session.target\"";
      description = "Systemd target to bind to.";
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
      description = "hypridle configuration written in Nix.";
    };
  };

  config = lib.mkIf (cfg.enable && hyprland.enable && cfg.package != null) {
    xdg.config.files."hypr/hypridle.conf" = {
      source = confPath;
    };

    system.systemd.user.services.hypridle = {
      Install = {
        WantedBy = [ cfg.systemdTarget ];
      };

      Unit = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        Description = "hypridle";
        After = [ cfg.systemdTarget ];
        PartOf = [ cfg.systemdTarget ];
        "X-Restart-Triggers" = lib.optional (cfg.settings != { }) confPath;
      };

      Service = {
        ExecStart = "${lib.getExe cfg.package}";
        Restart = "always";
        RestartSec = "10";
      };
    };
  };
}
