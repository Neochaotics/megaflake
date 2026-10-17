# uwsm session autostart.
#
# Ported from `modules/ff/windowManagers/windowManagers.nix`, which used to
# start the uwsm session from a home-manager user service.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.windowManager;
in
{
  options.windowManager = {
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to automatically start the window manager session on user
        login.
      '';
    };
  };

  config = lib.mkIf cfg.autoStart {
    system.systemd.user.services.uwsm-start = {
      Unit = {
        Description = "Start uwsm session";
      };

      Service = {
        ExecStart = "${pkgs.bash}/bin/bash -lc ''if uwsm check may-start && uwsm select; then exec uwsm start default; fi''";
        Type = "simple";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
