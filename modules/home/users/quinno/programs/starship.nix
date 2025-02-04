{
  lib,
  config,
  ...
}:
let
  cfg = config.cm.home.users.quinno.programs.starship;
in
{
  options.cm.home.users.quinno.programs.starship = {
    enable = lib.mkEnableOption "Enable";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      # settings = {};
    };
  };
}
