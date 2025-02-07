{ lib, config, ... }:

let
  cfg = config.cm.nixos.programs.nh;
in
{
  options.cm.nixos.programs.nh = {
    enable = lib.mkEnableOption "Enable nh";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      nh = {
        enable = true;
        flake = "/etc/nixos";
      };
    };
  };
}
