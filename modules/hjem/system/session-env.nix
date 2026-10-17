# Session environment: exports the session variables Home Manager used to
# export, writes `environment.d/10-home-manager.conf` for systemd, and builds
# the `hm-session-vars.sh` package the shell modules source.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.system.session;

  # Falling back to the full set keeps the common case short, mirroring
  # home-manager, where `systemd.user.sessionVariables` defaulted to the
  # session variables a module explicitly opted in with.
  systemdVariables = if cfg.systemdVariables != { } then cfg.systemdVariables else cfg.variables;

  inherit (lib) concatStringsSep mapAttrsToList toString;

  exportVar =
    n: v:
    let
      value = if builtins.isBool v then lib.boolToString v else toString v;
    in
    ''export ${n}="${value}"'';

  exportAll =
    vars: concatStringsSep "\n" (mapAttrsToList exportVar (lib.filterAttrs (_k: v: v != null) vars));

  prependToVar =
    sep: n: v:
    "${concatStringsSep sep v}\${${n}:+${sep}}\$${n}";

  sessionVariablesPackage = pkgs.writeTextFile {
    name = "hm-session-vars.sh";
    destination = "/etc/profile.d/hm-session-vars.sh";
    text = ''
      # Only source this once.
      if [ -n "''${__HM_SESS_VARS_SOURCED-}" ]; then return; fi
      export __HM_SESS_VARS_SOURCED=1

      ${exportAll cfg.variables}
    ''
    + concatStringsSep "\n" (
      mapAttrsToList (env: values: exportVar env (prependToVar ":" env values)) cfg.searchVariables
    )
    + "\n"
    + cfg.variablesExtra;
  };
in
{
  options.system.session = {
    enable = lib.mkEnableOption "session environment management";

    variables = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.bool
          lib.types.int
          lib.types.str
        ]
      );
      default = { };
      example = {
        EDITOR = "nvim";
        TERMINAL = "foot";
      };
      description = ''
        Session variables to export.

        They are written to
        {file}`$XDG_CONFIG_HOME/environment.d/10-home-manager.conf`
        for systemd, exported to the hjem session environment, and collected
        into {file}`hm-session-vars.sh` for shell startup files.
      '';
    };

    searchVariables = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = { };
      example = {
        MANPATH = [ "$HOME/.npm-packages/man" ];
      };
      description = ''
        Extra PATH-like variables whose list values are concatenated with `:`
        and exported once.
      '';
    };

    variablesExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Verbatim extra content appended to {file}`hm-session-vars.sh`.";
    };

    # home-manager wrote only a subset of the session variables to
    # `environment.d`: the ones systemd and the D-Bus daemon need. The rest
    # live only in `hm-session-vars.sh`.
    systemdVariables = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.bool
          lib.types.int
          lib.types.str
        ]
      );
      default = { };
      example = {
        XDG_DATA_DIRS = "/run/current-system/sw/share";
      };
      description = ''
        Session variables written to
        {file}`$XDG_CONFIG_HOME/environment.d/10-home-manager.conf`.

        Defaults to {option}`system.session.variables` when it is not set
        explicitly.
      '';
    };

    variablesPackage = lib.mkOption {
      type = lib.types.package;
      internal = true;
      default = sessionVariablesPackage;
      defaultText = lib.literalExpression "sessionVariablesPackage";
      readOnly = true;
      description = ''
        The package containing the {file}`hm-session-vars.sh` file, sourced by
        the shell startup files.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables = cfg.variables;

    packages = [ sessionVariablesPackage ];

    xdg.config.files."environment.d/10-home-manager.conf".text = lib.mkIf (systemdVariables != { }) (
      concatStringsSep "\n" (mapAttrsToList (n: v: "${n}=${toString v}") systemdVariables) + "\n"
    );
  };
}
