{
  lib,
  config,
  ...
}:
let
  cfg = config.qm.desktop.hypr;
in
{
  options.qm.desktop.hypr.sunset = {
    enable = lib.mkEnableOption "Enable";
  };

  config = lib.mkIf (cfg.sunset.enable && cfg.land.enable) {
    services.hyprsunset = {
      enable = true;
      settings = {
        max-gamma = 150;

        profile = [
          {
            time = "7:30";
            identity = true;
          }
          {
            time = "21:00";
            temperature = 3700;
            gamma = 0.6;
          }
        ];
      };

    };
  };
}
