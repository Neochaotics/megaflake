# bash configuration.
#
# Ported from home-manager's `modules/programs/bash.nix` (BSD-3-Clause, (c)
# Home Manager contributors). The generated `.bash_profile`, `.profile` and
# `.bashrc` use the same templates, so they are byte-identical.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.bash;

  shell = import ../lib/shell.nix { inherit lib; };

  writeBashScript =
    name: text:
    pkgs.writeTextFile {
      inherit name text;
      checkPhase = ''
        ${pkgs.stdenv.shellDryRun} "$target"
      '';
    };

  aliasesStr = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (k: v: "alias -- ${k}=${lib.escapeShellArg v}") cfg.shellAliases
  );

  shoptsStr =
    let
      switch = v: if lib.hasPrefix "-" v then "-u" else "-s";
    in
    lib.concatStringsSep "\n" (map (v: "shopt ${switch v} ${lib.removePrefix "-" v}") cfg.shellOptions);

  historyControlStr = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (n: v: "${n}=${v}") (
      lib.optionalAttrs (cfg.historyFileSize != null) {
        HISTFILESIZE = toString cfg.historyFileSize;
      }
      // lib.optionalAttrs (cfg.historySize != null) {
        HISTSIZE = toString cfg.historySize;
      }
      // lib.optionalAttrs (cfg.historyFile != null) {
        HISTFILE = ''"${cfg.historyFile}"'';
      }
      // lib.optionalAttrs (cfg.historyControl != [ ]) {
        HISTCONTROL = lib.concatStringsSep ":" cfg.historyControl;
      }
      // lib.optionalAttrs (cfg.historyIgnore != [ ]) {
        HISTIGNORE = lib.escapeShellArg (lib.concatStringsSep ":" cfg.historyIgnore);
      }
    )
  );
in
{
  options.programs.bash = {
    enable = lib.mkEnableOption "bash";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bashInteractive;
      defaultText = lib.literalExpression "pkgs.bashInteractive";
      description = "The bash package to install.";
    };

    enableCompletion = lib.mkEnableOption "bash completion" // {
      default = false;
    };

    shellOptions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        # Append to history file rather than replacing it.
        "histappend"

        # Extended globbing.
        "extglob"
        "globstar"

        # Warn if closing shell with running jobs.
        "checkjobs"
      ];
      example = [
        "extglob"
        "globstar"
      ];
      description = "Bash shell options to enable.";
    };

    shellAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        ll = "eza -l";
      };
      description = "Aliases added to `bash`.";
    };

    sessionVariables = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.bool
          lib.types.int
          lib.types.str
        ]
      );
      default = { };
      description = ''
        Environment variables that are set inside `bash`.
        This will not be set for `sudo`, because `sudo` does not preserve
        environment variables.
      '';
    };

    historyControl = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "ignoreboth"
      ];
      description = ''
        Set the {command}`bash` history control options.
      '';
    };

    historyIgnore = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "clear"
        "exit"
      ];
      description = ''
        Set the commands to ignore in the history.
      '';
    };

    historySize = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      example = 1000;
      description = ''
        Sets the number of history lines to keep.
      '';
    };

    historyFileSize = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      example = 1000;
      description = ''
        Sets the number of history lines to keep in the history file.
      '';
    };

    historyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "~/.bash_history";
      description = ''
        Sets the path to the {command}`bash` history file.
      '';
    };

    initExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Commands to run in {file}`.bashrc`.
      '';
    };

    bashrcExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Commands that should be placed at the beginning of {file}`.bashrc`.
      '';
    };

    profileExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Commands to add to {file}`.profile`.
      '';
    };

    logoutExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra commands that should be run when logging out of an
        interactive shell.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        packages = lib.mkIf (cfg.package != null) [ cfg.package ];

        files.".bash_profile".source = writeBashScript "bash_profile" ''
          # include .profile if it exists
          [[ -f ~/.profile ]] && . ~/.profile

          # include .bashrc if it exists
          [[ -f ~/.bashrc ]] && . ~/.bashrc
        '';

        files.".profile".source = writeBashScript "profile" ''
          . "${config.system.session.variablesPackage}/etc/profile.d/hm-session-vars.sh"

          ${shell.exportAll cfg.sessionVariables}

          ${cfg.profileExtra}
        '';

        files.".bashrc".source = writeBashScript "bashrc" ''
          ${cfg.bashrcExtra}

          # Commands that should be applied only for interactive shells.
          [[ $- == *i* ]] || return

          ${historyControlStr}

          ${shoptsStr}

          ${aliasesStr}

          ${cfg.initExtra}
        '';

        files.".bash_logout" = lib.mkIf (cfg.logoutExtra != "") {
          source = writeBashScript "bash_logout" cfg.logoutExtra;
        };
      }

      # If completion is enabled then make sure it is sourced very early. This
      # is to avoid problems if any other initialization code attempts to set
      # up completion.
      (lib.mkIf cfg.enableCompletion {
        programs.bash.initExtra = lib.mkOrder 100 ''
          if [[ ! -v BASH_COMPLETION_VERSINFO ]]; then
            . "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
          fi
        '';
      })
    ]
  );
}
