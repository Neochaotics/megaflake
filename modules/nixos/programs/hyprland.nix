{ lib, config, ... }:
let
  cfg = config.cm.nixos.programs.hyprland;
in
{
  options.cm.nixos.programs.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland with UWSM";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      uwsm.enable = true;
      hyprland = {
        enable = true;
        withUWSM = true;
      };
    };
  };
}
