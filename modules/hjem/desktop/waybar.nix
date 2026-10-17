# waybar configuration.
#
# Ported from home-manager's `modules/programs/waybar.nix` (BSD-3-Clause, (c)
# Home Manager contributors): same JSON generation, same file names and the
# same user service.
{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = config.desktop.waybar;

  jsonFormat = pkgs.formats.json { };

  persistentWorkspaces = lib.filterAttrs (_: workspaces: workspaces != [ ]) (
    lib.mapAttrs (_: cfg: cfg.workspaces) osConfig.freedpom.hardware.displays
  );

  # The NixOS display definitions own the workspace layout, so mirror the
  # per-output workspaces into waybar rather than duplicating them by hand.
  settings = map (
    s:
    if (s."hyprland/workspaces" or null) == null then
      s
    else
      s
      // {
        "hyprland/workspaces" = s."hyprland/workspaces" // {
          "persistent-workspaces" = persistentWorkspaces;
        };
      }
  ) cfg.settings;
in
{
  options.desktop.waybar = {
    enable = lib.mkEnableOption "waybar";

    package = lib.mkPackageOption pkgs "waybar" { };

    systemd = {
      enable = lib.mkEnableOption "waybar systemd integration" // {
        default = true;
      };

      targets = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "graphical-session.target" ];
        defaultText = lib.literalExpression ''[ "graphical-session.target" ]'';
        description = "The systemd targets that will automatically start Waybar.";
      };

      enableInspect = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to append `--inspect` to the `ExecStart` command line, for
          debugging CSS.
        '';
      };

      enableDebug = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to append `-l debug` to the `ExecStart` command line.";
      };
    };

    settings = lib.mkOption {
      type = jsonFormat.type;
      default = [ ];
      example = lib.literalExpression ''
        [
          {
            layer = "top";
            modules-left = [ "hyprland/workspaces" ];
          }
        ]
      '';
      description = ''
        Waybar configuration, written to {file}`waybar/config`.
        See <https://github.com/Alexays/Waybar/wiki/Configuration> for all available options.
      '';
    };

    style = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      example = ''
        * {
          border: none;
          border-radius: 0;
          min-height: 0;
        }
      '';
      description = "CSS style of the bar, written to {file}`waybar/style.css`.";
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [ cfg.package ];

    xdg.config.files."waybar/config" = lib.mkIf (settings != [ ]) {
      source = jsonFormat.generate "waybar-config.json" settings;
    };

    xdg.config.files."waybar/style.css" = lib.mkIf (cfg.style != null) {
      source = pkgs.writeText "waybar/style.css" cfg.style;
    };

    systemd = lib.mkMerge [
      (lib.mkIf cfg.systemd.enable {
        services.waybar = {
          description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
          documentation = [ "https://github.com/Alexays/Waybar/wiki" ];
          partOf = [ "tray.target" ] ++ cfg.systemd.targets;
          after = cfg.systemd.targets;
          wantedBy = [ "tray.target" ] ++ cfg.systemd.targets;
          unitConfig = {
            ConditionEnvironment = "WAYLAND_DISPLAY";
            "X-Reload-Triggers" =
              lib.optional (settings != [ ]) "${config.xdg.config.files."waybar/config".source}"
              ++ lib.optional (cfg.style != null) "${config.xdg.config.files."waybar/style.css".source}";
          };

          serviceConfig = {
            Environment = lib.optional cfg.systemd.enableInspect "GTK_DEBUG=interactive";
            ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
            ExecStart = "${cfg.package}/bin/waybar${lib.optionalString cfg.systemd.enableDebug " -l debug"}";
            KillMode = "mixed";
            Restart = "on-failure";
          };
        };

        targets.tray = {
          description = "Home Manager System Tray";
          requires = [ "graphical-session-pre.target" ];
        };
      })
    ];
  };
}
