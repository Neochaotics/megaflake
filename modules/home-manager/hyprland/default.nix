{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.qm.desktop.hypr.land;
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

    ./ecosystem/hyprsunset.nix
    ./ecosystem/idle-lock.nix

    ./plugins/dynamic-cursors.nix
    ./plugins/hyprexpo.nix
  ];

  options.qm.desktop.hypr.land = {
    enable = lib.mkEnableOption "Enable Hyprland configuration";
  };

  config = lib.mkIf cfg.enable {

    systemd.user.services.uwsm-start = {
      Unit = {
        Description = "Start UWSM.";
        After = "graphical-session-pre.target";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        Type = "simple";
        Environment = "PATH=/run/wrappers/bin:/home/quinno/.local/share/flatpak/exports/bin:/var/lib/flatpak/exports/bin:/home/quinno/.nix-profile/bin:/nix/profile/bin:/home/quinno/.local/state/nix/profile/bin:/etc/profiles/per-user/quinno/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/nix/store/kc5qpmifdfdwvfys37zggnbnsq3nvrzk-pciutils-3.14.0/bin:/nix/store/skz92bkx4r4bp9ddczzsi02yrywmr1nc-pkgconf-wrapper-2.4.3/bin";
        ExecStart = "/run/current-system/sw/bin/uwsm start hyprland-uwsm.desktop";
        Restart = "no";
      };
    };

    home.pointerCursor.hyprcursor.enable = true;
    home.packages = with pkgs; [
      wl-clipboard
      hyprpolkitagent
      hyprland-qtutils
    ];

    wayland = {
      #systemd.target = "hyprland-session.target";
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
