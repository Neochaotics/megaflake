# systemd user units.
#
# Hjem has no `systemd.user.services`, so units and their `.wants` symlinks are
# written into `$XDG_CONFIG_HOME/systemd/user` as plain files. The unit bodies
# come from home-manager's `modules/systemd.nix` renderer (BSD-3-Clause, (c)
# Home Manager contributors) so the files are byte-identical.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.system.systemd.user;

  primitive =
    with types;
    oneOf [
      bool
      int
      str
      path
    ];

  unitBaseType =
    unitKind: mod:
    types.submodule {
      freeformType =
        with types;
        attrsOf (attrsOf (either primitive (listOf primitive)))
        // {
          description = "systemd ${unitKind} unit configuration";
        };

      imports = [
        {
          options.Unit = {
            Description = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "A short human-readable label of the unit.";
            };

            Documentation = mkOption {
              type = with types; coercedTo str lib.toList (listOf str);
              default = [ ];
              description = "List of URIs referencing documentation for the unit.";
            };
          };
        }

        mod
      ];
    };

  serviceType = types.attrsOf (
    unitBaseType "service" {
      options.Service = {
        Environment = mkOption {
          type = with types; coercedTo str lib.toList (listOf str);
          default = [ ];
          description = "Environment variables available to executed processes.";
        };

        ExecStart = mkOption {
          type =
            with types;
            let
              p = either package str;
            in
            either p (listOf p);
          apply = lib.toList;
          default = [ ];
          description = "Command that is executed when this service is started.";
        };
      };
    }
  );

  systemdLib = import ../lib/systemd.nix { inherit lib pkgs; };
  inherit (systemdLib) buildUnits;
in
{
  options.system.systemd.user = {
    enable = mkEnableOption "systemd user units" // {
      default = true;
    };

    services = mkOption {
      type = serviceType;
      default = { };
      example = lib.literalExpression ''
        {
          my-service = {
            Unit = {
              Description = "My service";
              After = [ "network.target" ];
            };
            Service = {
              ExecStart = "${pkgs.hello}/bin/hello";
              Type = "oneshot";
            };
            Install.WantedBy = [ "default.target" ];
          };
        }
      '';
      description = "User services to generate.";
    };

    targets = mkOption {
      type = types.attrsOf (unitBaseType "target" { });
      default = { };
      description = "User targets to generate.";
    };

    slices = mkOption {
      type = types.attrsOf (unitBaseType "slice" { });
      default = { };
      description = "User slices to generate.";
    };

    timers = mkOption {
      type = types.attrsOf (unitBaseType "timer" { });
      default = { };
      description = "User timers to generate.";
    };

    sockets = mkOption {
      type = types.attrsOf (unitBaseType "socket" { });
      default = { };
      description = "User sockets to generate.";
    };
  };

  config = mkIf cfg.enable {
    xdg.config.files = lib.listToAttrs (
      buildUnits "service" cfg.services
      ++ buildUnits "target" cfg.targets
      ++ buildUnits "slice" cfg.slices
      ++ buildUnits "timer" cfg.timers
      ++ buildUnits "socket" cfg.sockets
    );
  };
}
