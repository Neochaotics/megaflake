{ lib, config, ... }:
let
  cfg = config.qm.programs.zellij;
in
{
  options.qm.programs.zellij = {
    enable = lib.mkEnableOption "Enable zellij configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
    };
  };
}
