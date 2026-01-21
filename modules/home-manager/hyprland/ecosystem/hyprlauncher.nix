{
  lib,
  config,
  ...
}:
let
  cfg = config.qm.desktop.hypr;
in
{
  options.qm.desktop.hypr.launcher = {
    enable = lib.mkEnableOption "Enable";
  };

  config = lib.mkIf (cfg.launcher.enable && cfg.land.enable) {

  };
}
