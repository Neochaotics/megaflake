{
  lib,
  config,
  pkgs,
  inputs,
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
    ./env.nix

    ./bindings.nix
    ./monitors.nix
    ./windowrules.nix

    ./idlelock.nix

    ./plugins/dynamic-cursors.nix
    ./plugins/hyprexpo.nix
  ];

  options.qm.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland configuration";
  };

  config = lib.mkIf cfg.enable {
    home.pointerCursor.hyprcursor.enable = true;
    home.packages = with pkgs; [
      wl-clipboard
      hyprpolkitagent
      hyprland-qtutils
    ];

    wayland = {
      systemd.target = "hyprland-session.target";
      windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        systemd = {
          enable = false;
          enableXdgAutostart = false;
        };

        xwayland.enable = true;

        plugins = [
          #inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
          inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprfocus
          #inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.xtra-dispatchers
        ];
      };
    };
  };
}
