# zoxide configuration.
#
# Ported from home-manager's `modules/programs/zoxide.nix` (BSD-3-Clause, (c)
# Home Manager contributors): same shell integration snippets and ordering.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.zoxide;
  inherit (lib) concatStringsSep mkOrder;
in
{
  options.programs.zoxide = {
    enable = lib.mkEnableOption "zoxide";

    package = lib.mkPackageOption pkgs "zoxide" { };

    options = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "--cmd"
        "cd"
      ];
      description = "Options passed to `zoxide init`.";
    };

    enableBashIntegration = lib.mkEnableOption "bash integration" // {
      default = true;
    };

    enableZshIntegration = lib.mkEnableOption "zsh integration" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [ cfg.package ];

    programs.bash.initExtra = lib.mkIf cfg.enableBashIntegration (
      mkOrder 2000 ''
        eval "$(${lib.getExe cfg.package} init bash ${concatStringsSep " " cfg.options})"
      ''
    );

    programs.zsh.initExtra = lib.mkIf cfg.enableZshIntegration {
      # After `compInit` in `zsh`
      "851" = ''
        eval "$(${lib.getExe cfg.package} init zsh ${concatStringsSep " " cfg.options})"
      '';
    };
  };
}
