{
  lib,
  config,
  ...
}: let
  cfg = config.qm.antec-display;
in {
  options.qm.antec-display = {
    enable = lib.mkEnableOption "Enable";
  };

  config =
    lib.mkIf cfg.enable {
    };
}
