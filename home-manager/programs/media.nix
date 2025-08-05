{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.qm.programs.media;
in {
  options.qm.programs.media = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.stremio
      pkgs.tidal-hifi
      pkgs.alsa-scarlett-gui
    ];
  };
}
