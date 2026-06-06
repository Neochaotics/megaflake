{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.freedpom.windowManagers.hyprland;
in
{
  options.freedpom.windowManagers.hyprland = {
    enable = lib.mkEnableOption "Hyprland dynamic tiling Wayland compositor";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      uwsm.enable = true;
      hyprland = {
        enable = true;
        withUWSM = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
    };
    hardware.graphics =
      let
        hyprpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
      in
      {
        package = hyprpkgs.mesa;
        enable32Bit = true;
        package32 = hyprpkgs.pkgsi686Linux.mesa;
      };
  };
}
