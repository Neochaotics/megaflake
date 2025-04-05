{ lib, config, ... }:
let
  cfg = config.qm.programs.starship;
in
{
  options.qm.programs.starship = {
    enable = lib.mkEnableOption "Enable";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      presets = [
        "nerd-font-symbols"
        "no-empty-icons"
        "jetpack"
      ];
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
  };
}
