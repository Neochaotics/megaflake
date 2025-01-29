{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.cm.home.users.quinno.programs.fuzzel;
in
{
  options.cm.home.users.quinno.programs.fuzzel = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {
      programs.fuzzel = {
        enable = true;
      };
  };
}
