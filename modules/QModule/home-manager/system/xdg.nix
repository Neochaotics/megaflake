{ config, lib, ... }:
let
  cfg = config.cm.home.users.quinno.system.xdg;
in
{
  options.cm.home.users.quinno.system.xdg = {
    enable = lib.mkEnableOption "Enables XDG directory configuration and default paths";
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      enable = true;
      cacheHome = config.home.homeDirectory + "/.local/cache";

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
