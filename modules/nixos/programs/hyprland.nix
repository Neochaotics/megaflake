{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.qm.programs.hyprland;
in
{
  options.qm.programs.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland";
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
        package = lib.mkForce hyprpkgs.mesa;
        enable32Bit = lib.mkForce true;
        package32 = lib.mkForce hyprpkgs.pkgsi686Linux.mesa;
      };
  };
}
