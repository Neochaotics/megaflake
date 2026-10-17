# fzf configuration.
#
# Ported from home-manager's `modules/programs/fzf.nix` (BSD-3-Clause, (c) Home
# Manager contributors): same shell integration snippets and init ordering.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.fzf;
  inherit (lib) mkIf mkOrder;
in
{
  options.programs.fzf = {
    enable = lib.mkEnableOption "fzf";

    package = lib.mkPackageOption pkgs "fzf" { };

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
        programs.bash.initExtra = mkOrder 900 ''
          if [[ :$SHELLOPTS: =~ :(vi|emacs): ]]; then
            eval "$(${lib.getExe cfg.package} --bash)"
          fi
        '';
      })

      (mkIf cfg.enableZshIntegration {
        # Still needs to be initialized after oh-my-zsh (order 800), otherwise
        # omz will take precedence.
        programs.zsh.initExtra."910" = ''
          if [[ $options[zle] = on ]]; then
            source <(${lib.getExe cfg.package} --zsh)
          fi
        '';
      })
    ]
  );
}
