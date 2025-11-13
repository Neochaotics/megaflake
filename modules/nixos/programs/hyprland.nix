{
  lib,
  config,
  ...
}: let
  cfg = config.qm.programs.hyprland;
in {
  options.qm.programs.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland with UWSM";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      uwsm.enable = false;
      hyprland = {
        enable = true;
        withUWSM = false;
        #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        #portalPackage =
        #  inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
    };
  };
}
