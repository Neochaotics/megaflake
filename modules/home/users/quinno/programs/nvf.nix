{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.cm.home.users.quinno.programs.nvf;
in
{

  imports = [ inputs.nvf.homeManagerModules.default ];

  options.cm.home.users.quinno.programs.nvf = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {

  };
}
