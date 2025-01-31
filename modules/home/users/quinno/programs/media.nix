{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.cm.home.users.quinno.programs.media;
in
{
  options.cm.home.users.quinno.programs.media = {
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
