{
  lib,
  config,
  ...
}: let
  cfg = config.qm.programs.foot;
in {
  options.qm.programs.foot = {
    enable = lib.mkEnableOption "Enable foot terminal configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      settings = {
        cursor = {
          blink = true;
        };
      };
    };
  };
}
