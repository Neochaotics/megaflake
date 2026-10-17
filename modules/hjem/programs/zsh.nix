# zsh configuration.
#
# Ported from home-manager's `modules/programs/zsh/{default,history,lib}.nix`
# (BSD-3-Clause, (c) Home Manager contributors). Covers the subset this host
# uses: completion, syntax highlighting, autosuggestions, history, `autocd`,
# shell aliases, and `dotDir`, with the same init ordering so the generated
# `.zshrc` is byte-identical.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.zsh;

  shell = import ../lib/shell.nix { inherit lib; };

  inherit (lib)
    concatStringsSep
    escapeShellArg
    mapAttrsToList
    optionalString
    ;

  dotDirAbs =
    if lib.hasPrefix "/" cfg.dotDir then
      cfg.dotDir
    else
      throw "programs.zsh.dotDir must be an absolute path";
  dotDirRel = lib.removePrefix "${config.directory}/" dotDirAbs;

  indentNonEmptyLines =
    str:
    lib.concatStringsSep "\n" (
      map (line: if line == "" then "" else "  ${line}") (lib.splitString "\n" str)
    );

  envVarsStr = shell.exportAll cfg.sessionVariables;

  sessionVarsStr = lib.removeSuffix "\n" ''
    # Environment variables
    . "${config.system.session.variablesPackage}/etc/profile.d/hm-session-vars.sh"

    # Only source this once
    if [[ -z "''${__HM_ZSH_SESS_VARS_SOURCED-}" ]]; then
      export __HM_ZSH_SESS_VARS_SOURCED=1
      ${envVarsStr}
    fi
  '';

  aliasesStr = concatStringsSep "\n" (
    mapAttrsToList (k: v: "alias -- ${escapeShellArg k}=${escapeShellArg v}") cfg.shellAliases
  );

  # home-manager derives the zsh `setopt` list from the history submodule.
  historyOptions = {
    APPEND_HISTORY = cfg.history.append;
    HIST_IGNORE_DUPS = cfg.history.ignoreDups;
    HIST_IGNORE_ALL_DUPS = cfg.history.ignoreAllDups;
    HIST_SAVE_NO_DUPS = cfg.history.saveNoDups;
    HIST_FIND_NO_DUPS = cfg.history.findNoDups;
    HIST_IGNORE_SPACE = cfg.history.ignoreSpace;
    HIST_EXPIRE_DUPS_FIRST = cfg.history.expireDuplicatesFirst;
    SHARE_HISTORY = cfg.history.share;
    EXTENDED_HISTORY = cfg.history.extended;
  }
  // lib.optionalAttrs (cfg.autocd != null) {
    inherit (cfg) autocd;
  };

  enabledOpts = lib.filterAttrs (_: enabled: enabled) historyOptions;
  disabledOpts = lib.filterAttrs (_: enabled: !enabled) historyOptions;

  setOptions = [
    "HIST_FCNTL_LOCK"
  ]
  ++ mapAttrsToList (name: _: name) enabledOpts
  ++ mapAttrsToList (name: _: "NO_" + name) disabledOpts;

  # Home-manager ordered these with `mkOrder`. Entries keyed by their numeric
  # order reproduce that ordering (`lib.sortBy` is stable, so equal orders keep
  # their definition order) while other modules can still add their own.
  initContent = [
    {
      order = 510;
      text = "typeset -U path cdpath fpath manpath";
    }
    {
      order = 520;
      text = ''
        for profile in ''${(z)NIX_PROFILES}; do
          fpath+=($profile/share/zsh/site-functions $profile/share/zsh/$ZSH_VERSION/functions $profile/share/zsh/vendor-completions)
        done
      '';
    }
    {
      order = 520;
      text = ''
        HELPDIR="${cfg.package}/share/zsh/$ZSH_VERSION/help"
      '';
    }
  ]
  ++ lib.optional cfg.enableCompletion {
    # NOTE: Oh-My-Zsh/Prezto calls compinit during initialization, calling it
    # twice causes slight start up slowdown.
    order = 570;
    text = cfg.completionInit;
  }
  ++ lib.optional cfg.autosuggestion.enable {
    order = 700;
    text = ''
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      ${
        optionalString (cfg.autosuggestion.strategy != [ ]) ''
          ZSH_AUTOSUGGEST_STRATEGY=(${concatStringsSep " " cfg.autosuggestion.strategy})
        ''
      }${
        optionalString (cfg.autosuggestion.highlight != null) ''
          ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="${cfg.autosuggestion.highlight}"
        ''
      }
    '';
  }
  ++ [
    {
      order = 910;
      text = ''
        # History options should be set in .zshrc and after oh-my-zsh sourcing.
        # See https://github.com/nix-community/home-manager/issues/177.
        HISTSIZE="${toString cfg.history.size}"
        SAVEHIST="${toString cfg.history.save}"
        ${optionalString (
          cfg.history.ignorePatterns != [ ]
        ) "HISTORY_IGNORE=${escapeShellArg "(${concatStringsSep "|" cfg.history.ignorePatterns})"}"}
        HISTFILE="${cfg.history.path}"
        mkdir -p "$(dirname "$HISTFILE")"
      '';
    }
  ]
  ++ lib.optional (setOptions != [ ]) {
    order = 950;
    text = ''
      # Set shell options
      set_opts=(${shell.formatShellArrayContent setOptions})
      for opt in "''${set_opts[@]}"; do
        setopt "$opt"
      done
      unset opt set_opts
    '';
  }
  ++ lib.optional (aliasesStr != "") {
    order = 1100;
    text = aliasesStr;
  }
  ++ lib.optional cfg.syntaxHighlighting.enable {
    # Load zsh-syntax-highlighting after all custom widgets have been created
    # https://github.com/zsh-users/zsh-syntax-highlighting#faq
    order = 1200;
    text = ''
      source ${cfg.syntaxHighlighting.package}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      ZSH_HIGHLIGHT_HIGHLIGHTERS=(${concatStringsSep " " (map escapeShellArg cfg.syntaxHighlighting.highlighters)})
      ${concatStringsSep "\n" (
        mapAttrsToList (
          name: value: "ZSH_HIGHLIGHT_STYLES[${escapeShellArg name}]=${escapeShellArg value}"
        ) (cfg.syntaxHighlighting.styles)
      )}
      ${concatStringsSep "\n" (
        mapAttrsToList (
          name: value: "ZSH_HIGHLIGHT_PATTERNS+=(${escapeShellArg name} ${escapeShellArg value})"
        ) cfg.syntaxHighlighting.patterns
      )}
    '';
  };

  # `programs.zsh.initExtra` contributions, keyed by order, like home-manager's
  # `mkOrder` values.
  externalInitContent = lib.mapAttrsToList (order: text: {
    text = text;
    order = lib.toInt order;
  }) cfg.initExtra;
in
{
  options.programs.zsh = {
    enable = lib.mkEnableOption "zsh";

    package = lib.mkPackageOption pkgs "zsh" { };

    enableCompletion = lib.mkEnableOption "zsh completion" // {
      default = false;
    };

    completionInit = lib.mkOption {
      type = lib.types.lines;
      default = "autoload -U compinit && compinit";
      description = ''
        Commands to append to {file}`.zshrc` for setting up completion.
      '';
    };

    autocd = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      example = false;
      description = ''
        Set the `autocd` option, executing a cd command when a directory is
        typed.
      '';
    };

    dotDir = lib.mkOption {
      type = lib.types.path;
      default = config.directory;
      defaultText = lib.literalExpression "config.directory";
      example = "${config.directory}/.zsh";
      description = ''
        Directory to use for zsh dotfiles, must be an absolute path without
        shell variables.
      '';
    };

    shellAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        ll = "eza -l";
      };
      description = "Aliases added to {file}`.zshrc`.";
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
        Variables exported in {file}`.zshenv`.
      '';
    };

    initExtra = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      default = { };
      example = {
        "1200" = ''
          source ${pkgs.starship}/bin/starship-init.zsh
        '';
      };
      description = ''
        Extra commands to add to {file}`.zshrc`.

        The attribute name is the numeric init order, the same value
        home-manager's {function}`lib.mkOrder` used: 510 sets up `fpath`, 570
        runs `compinit`, 851/910 hook in zoxide and fzf, 950 applies
        `setopt`, 1100 defines aliases and 1200 loads syntax highlighting.
      '';
    };

    envExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Commands to add to {file}`$ZDOTDIR/.zshenv`.
      '';
    };

    profileExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Commands to add to {file}`$ZDOTDIR/.zprofile`.
      '';
    };

    autosuggestion = {
      enable = lib.mkEnableOption "zsh-autosuggestions" // {
        default = false;
      };

      strategy = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [
          "history"
        ];
        description = ''
          Strategies of selecting suggestions for zsh-autosuggestions.
        '';
      };

      highlight = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Set the zsh-autosuggestions highlight style.";
      };
    };

    syntaxHighlighting = {
      enable = lib.mkEnableOption "syntax highlighting" // {
        default = false;
      };

      package = lib.mkPackageOption pkgs "zsh-syntax-highlighting" { };

      highlighters = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          List of {command}`zsh-syntax-highlighters` to use.
        '';
      };

      styles = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        example = {
          "comment" = "fg=blue";
        };
        description = "Styles to apply to syntax tokens.";
      };

      patterns = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = { };
        example = {
          "**/*.nix" = "fg=cyan";
        };
        description = "Additional patterns to highlight.";
      };
    };

    history = {
      size = lib.mkOption {
        type = lib.types.int;
        default = 10000;
        description = "Number of history entries kept in memory.";
      };

      save = lib.mkOption {
        type = lib.types.int;
        default = cfg.history.size;
        defaultText = lib.literalExpression "config.programs.zsh.history.size";
        description = "Number of history entries written to the history file.";
      };

      path = lib.mkOption {
        type = lib.types.str;
        default = "${dotDirAbs}/.zsh_history";
        defaultText = lib.literalExpression "dotDirAbs + '/.zsh_history'";
        description = "Path to the history file.";
      };

      ignorePatterns = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          Patterns to be ignored by the history mechanism.
        '';
      };

      append = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If set to `true`, the history file will be appended to rather than
          overwritten.
        '';
      };

      ignoreDups = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          If set to `true`, duplicate commands are omitted from the history
          list when the new occurrence is added to the history list.
        '';
      };

      ignoreAllDups = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If set to `true`, duplicate commands are removed from the history
          list entirely.
        '';
      };

      saveNoDups = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If set to `true`, the history is not saved when an identical line
          exists.
        '';
      };

      findNoDups = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If set to `true`, the command being executed is not put into the
          history list.
        '';
      };

      ignoreSpace = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          If set to `true`, a command that had leading spaces typed at the
          prompt is not put into the history list.
        '';
      };

      expireDuplicatesFirst = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If set to `true`, duplicates are removed before longer, more recent
          duplicates are removed.
        '';
      };

      share = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          If set to `true`, both `HISTFILE` and `HISTSIZE` are shared among
          all shells.
        '';
      };

      extended = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If set to `true`, the extended history format is used.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [
      cfg.package
    ]
    ++ lib.optional cfg.enableCompletion (lib.lowPrio pkgs.nix-zsh-completions);

    files."${dotDirRel}/.zshrc".text = concatStringsSep "\n" (
      map (entry: entry.text) (
        # Sort by order, then by insertion index, so that equal orders keep the
        # sequence home-manager produced (fpath before HELPDIR, and so on).
        lib.sort (a: b: a.order < b.order || (a.order == b.order && a.seq < b.seq)) (
          lib.zipListsWith
            (
              seq: entry:
              entry
              // {
                inherit seq;
                inherit (entry) order text;
              }
            )
            (lib.range 0 (lib.length (initContent ++ externalInitContent) - 1))
            (initContent ++ externalInitContent)
        )
      )
    );

    # home-manager concatenated three separate `text` definitions for this
    # file: the session variables, the `ZDOTDIR` export (only when `dotDir` is
    # not the home directory) and `envExtra`.
    files."${dotDirRel}/.zshenv".text = ''
      if [[ ! -o login ]]; then
      ${indentNonEmptyLines sessionVarsStr}
      fi
    ''
    + lib.optionalString (dotDirAbs != config.directory) ''

      ${shell.export "ZDOTDIR" dotDirAbs}
    ''
    + lib.optionalString (cfg.envExtra != "") "\n${cfg.envExtra}";

    files.".zshenv".text = lib.optionalString (dotDirAbs != config.directory) ''
      source ${lib.escapeShellArg "${dotDirAbs}/.zshenv"}
    '';

    files."${dotDirRel}/.zprofile".text = ''
      ${sessionVarsStr}
    ''
    + optionalString (cfg.profileExtra != "") ''

      ${cfg.profileExtra}
    '';

    programs.zsh.syntaxHighlighting.highlighters = lib.mkIf cfg.syntaxHighlighting.enable [ "main" ];
  };
}
