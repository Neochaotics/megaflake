{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qm.desktop.niri;
in
{
  options.qm.desktop.niri = {
    enable = lib.mkEnableOption "Enable niri configuration";
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.user.services.uwsm-start = lib.mkIf cfg.autoStart {
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
        ExecStart = "/run/current-system/sw/bin/uwsm start -N ''Niri'' -D niri -C ''A scrollable-tiling Wayland compositor.'' -- ${pkgs.niri}";
        Restart = "no";
      };
    };

    ff.wayland.windowManager.niri = {
      enable = true;
      settings = {
        output = {
          "DP-2" = {
            mode = "2560x1440@179.960";
            focus-at-startup = { };
          };
        };
        binds = {
          "Super+R".spawn = "fuzzle";
          "Super+Return".spawn = "foot";
        };
        input = {
          mouse = {
            accel-profile = "flat";
            accel-speed = 0.0;
          };
        };
      };
    };
  };
}
