{
  lib,
  config,
  ...
}:
let
  cfg = config.qm.programs.mpv;
in
{
  options.qm.programs.mpv = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.mpv = {
      enable = true;
    };
  };
}
