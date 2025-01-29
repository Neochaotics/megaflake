{
  lib,
  config,
  ...
}:
let
  cfg = config.cm.home.users.quinno.programs.foot;
in
{
  options.cm.home.users.quinno.programs.foot = {
    enable = lib.mkEnableOption "Enable foot terminal configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.foot = {
      enable = true;
    };
  };
}
