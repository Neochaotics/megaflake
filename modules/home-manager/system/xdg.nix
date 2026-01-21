{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.qm.system.xdg;
in
{
  options.qm.system.xdg = {
    enable = lib.mkEnableOption "Enables XDG directory configuration and default paths";
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      enable = true;
      cacheHome = config.home.homeDirectory + "/.local/cache";

      portal = {
        enable = lib.mkForce true;
        config = {
          common = {
            default = [
              "gtk"
            ];
          };
          hyprland = {
            default = [
              "hyprland"
            ];
          };
        };
        extraPortals = [
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
        ];
      };

      mimeApps = {
        enable = true;
      };

      userDirs = {
        enable = true;
        createDirectories = true;
        extraConfig = {
          XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
        };
      };
    };
  };
}
