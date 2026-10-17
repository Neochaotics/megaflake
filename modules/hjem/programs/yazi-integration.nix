# yazi shell integration.
#
# The TOML configuration itself comes from `rum.programs.yazi`; this module
# ports home-manager's `modules/programs/yazi.nix` shell integration snippets
# (BSD-3-Clause, (c) Home Manager contributors) so `.bashrc`/`.zshrc` keep the
# `fm` wrapper function.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.yazi;

  inherit (lib) mkIf mkOrder;

  bashIntegration = ''
    function ${cfg.shellWrapperName}() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
      command yazi "$@" --cwd-file="$tmp"
      if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }
  '';
in
{
  options.programs.yazi = {
    enable = lib.mkEnableOption "yazi";

    package = lib.mkPackageOption pkgs "yazi" { };

    shellWrapperName = lib.mkOption {
      type = lib.types.str;
      default = "y";
      defaultText = lib.literalExpression ''"y"'';
      example = "yy";
      description = "Name of the shell wrapper to be called.";
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
        packages = [ cfg.package ];
      }

      (mkIf cfg.enableBashIntegration {
        programs.bash.initExtra = mkOrder 1000 bashIntegration;
      })

      (mkIf cfg.enableZshIntegration {
        programs.zsh.initExtra."1000" = bashIntegration;
      })
    ]
  );
}
