{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qm.desktop.hyprland;
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

  options.qm.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable Quinn's Hyprland configuration";
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables.NIXOS_OZONE_WL = "1";
    wayland.windowManager.hyprland = {
      enable = true;
      #package = null;
      #portalPackage = null;
      systemd = {
        enable = false;
        enableXdgAutostart = false;
      };

      xwayland.enable = true;

      #plugins = [ inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors ];

    };

    programs.bash.initExtra = ''
      if uwsm check may-start; then
        exec uwsm start -S hyprland-uwsm.desktop
      fi
    '';
  };
}
