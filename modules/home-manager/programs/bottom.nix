{
  lib,
  config,
  ...
}: let
  cfg = config.qm.programs.bottom;
in {
  options.qm.programs.bottom = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.bottom = {
      enable = true;
      #settings = {
      #};
    };
  };
}
