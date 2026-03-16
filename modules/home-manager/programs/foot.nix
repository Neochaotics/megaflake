{
  lib,
  config,
  ...
}:
let
  cfg = config.qm.programs.foot;
in
{
  options.qm.programs.foot = {
    enable = lib.mkEnableOption "Enable foot terminal configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
      settings = lib.mkForce {
        main = {
          font = "OverpassM Nerd Font Mono:size=18";
        };
        cursor = {
          blink = true;
        };
      };
    };
  };
}
