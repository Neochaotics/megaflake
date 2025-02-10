{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.cm.nixos.services.kmscon;
in
{
  options.cm.nixos.services.kmscon = {
    enable = lib.mkEnableOption "Enable kmscon";
  };

  config = lib.mkIf cfg.enable {
    services.kmscon = {
      enable = false;
      hwRender = true;
      fonts = [
        {
          name = "Source Code Pro";
          package = pkgs.source-code-pro;
        }
      ];
      useXkbConfig = true;
    };
    #systemd.services."kmsconvt@" = {
    #  aliases = lib.mkForce [ ];
    #};
  };
}
