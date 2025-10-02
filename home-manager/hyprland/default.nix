{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.qm.desktop.hyprland;
in {
  imports = [
    ./general.nix
    ./appearance.nix
    ./input.nix
    ./misc.nix
    ./env.nix

    ./bindings.nix
    #./monitors.nix
    ./windowrules.nix

    ./idlelock.nix

    ./plugins/dynamic-cursors.nix
  ];

  options.qm.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable Quinn's Hyprland configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      hyprpolkitagent
      hyprland-qtutils
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      #package = null;
      #portalPackage = null;
      systemd = {
        enable = true;
        enableXdgAutostart = true;
      };

      xwayland.enable = true;

      #plugins = [ inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors ];
    };
  };
}
