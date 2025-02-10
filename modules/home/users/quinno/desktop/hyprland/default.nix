{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.cm.home.users.quinno.desktop.hyprland;
in
{
  imports = [
    ./general.nix
    ./appearance.nix
    ./input.nix
    ./misc.nix

    ./bindings.nix
    ./monitors.nix
    ./windowrules.nix

    ./idlelock.nix

    ./plugins/dynamic-cursors.nix
  ];

  options.cm.home.users.quinno.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable Quinn's Hyprland configuration";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      systemd = {
        enable = false;
        enableXdgAutostart = false;
      };

      xwayland.enable = true;

      plugins = [ inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors ];

    };

    programs.bash.initExtra = ''
      if uwsm check may-start; then
        exec uwsm start -S hyprland-uwsm.desktop
      fi
    '';

    xdg.portal = {
      enable = lib.mkForce true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
        };
      };
    };
  };
}
