# eza configuration.
#
# Ported from home-manager's `modules/programs/eza.nix` (BSD-3-Clause, (c)
# Home Manager contributors): same aliases and the same `eza` alias value.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.eza;

  iconsOption =
    let
      v = if lib.isBool cfg.icons then (if cfg.icons then "auto" else null) else cfg.icons;
    in
    lib.optionals (v != null) [
      "--icons"
      v
    ];

  args = lib.escapeShellArgs (
    iconsOption
    ++ lib.optionals (cfg.colors != null) [
      "--color"
      cfg.colors
    ]
    ++ lib.optional cfg.git "--git"
    ++ cfg.extraOptions
  );

  optionsAlias = lib.optionalAttrs (args != "") { eza = "eza ${args}"; };

  aliases = builtins.mapAttrs (_name: value: lib.mkDefault value) {
    ls = "eza";
    ll = "eza -l";
    la = "eza -a";
    lt = "eza --tree";
    lla = "eza -la";
  };

  # The `eza` alias itself carries the icon/git options.
  ezaAlias = optionsAlias // aliases;
in
{
  options.programs.eza = {
    enable = lib.mkEnableOption "eza";

    package = lib.mkPackageOption pkgs "eza" { };

    icons = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.bool lib.types.str);
      default = null;
      example = "auto";
      description = ''
        Whether to enable icons.

        Can be either a boolean to enable/disable icons or an `icons` string to
        use a different icon theme. See `man eza` for available themes.
      '';
    };

    colors = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "imgs";
      description = ''
        What color scheme to use for the file types.

        See `man eza` for available color schemes.
      '';
    };

    git = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      example = true;
      description = ''
        Whether to use git status in the output for each directory.

        See `man eza` for more information.
      '';
    };

    extraOptions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "--group-directories-first"
        "--reverse"
      ];
      description = ''
        Extra options to pass to eza.
      '';
    };

    enableBashIntegration = lib.mkEnableOption "bash integration" // {
      default = true;
    };

    enableZshIntegration = lib.mkEnableOption "zsh integration" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        warnings = lib.optional (lib.isBool cfg.icons) ''
          Setting programs.eza.icons to a Boolean is deprecated.
          Please update your configuration so that

            programs.eza.icons = ${if cfg.icons then ''"auto"'' else "null"};

        '';

        packages = lib.mkIf (cfg.package != null) [ cfg.package ];

        programs.bash.shellAliases = lib.mkIf cfg.enableBashIntegration ezaAlias;

        programs.zsh.shellAliases = lib.mkIf cfg.enableZshIntegration ezaAlias;
      }
    ]
  );
}
