{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.cm.nixos.packages.sudo;
in
{
  options.cm.nixos.packages.sudo = {
    enable = lib.mkEnableOption "Enables alternative sudo implementation using sudo-rs instead of regular sudo";
  };

  config = lib.mkIf cfg.enable {
    security = {
      sudo = {
        enable = lib.mkForce false;
        extraConfig = lib.mkForce [ ];
      };
      sudo-rs = {
        enable = true;
        execWheelOnly = true;
      };
    };
  };
}
