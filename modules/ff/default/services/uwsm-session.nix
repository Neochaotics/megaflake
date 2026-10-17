# uwsm session launcher on tty1.
#
# Ported from freedpom's `modules/desktop/uwsm-session.nix` so the session
# start lives here instead of a per-user unit. Enable with
# `services.uwsm-session.enable`; the launcher is a *system* service because
# only system scope can grab tty1, establish the PAM/logind seat session, and
# displace `getty@tty1`. The compositor itself still runs as `user` inside
# their own systemd user manager.
{
  config,
  lib,
  ...
}:
let
  cfg = config.services.uwsm-session;
in
{
  options.services.uwsm-session = {
    enable = lib.mkEnableOption "uwsm default Wayland session on tty1";

    user = lib.mkOption {
      type = lib.types.str;
      default = "quinno";
      description = "Seat user owning the uwsm console session on tty1.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.uwsm.enable = true;

    # Keep `getty@tty1` out of the way entirely while the uwsm session owns
    # tty1. `switch-to-configuration switch` pulls in `autovt@tty1.service`
    # (the NixOS getty module adds it to `getty.target` whenever no display
    # manager is enabled) and starting it trips uwsm-session's `Conflicts=`,
    # which kills the running session on every rebuild. Masking the instance
    # plus dropping the getty.target want mirrors what NixOS does when
    # `services.displayManager` is enabled, and makes any start attempt a
    # harmless no-op.
    systemd.services."getty@tty1".enable = false;
    systemd.targets.getty.wants = lib.mkForce [ ];

    systemd.services."uwsm-session" = {
      description = "uwsm default Wayland session";
      wantedBy = [ "graphical.target" ];
      after = [
        "systemd-user-sessions.service"
        "systemd-logind.service"
        "plymouth-quit-wait.service"
        "sound.target"
        "bluetooth.target"
      ];
      conflicts = [ "getty@tty1.service" ];
      # A rebuild that edits this unit should not tear down the live session;
      # the mask/want changes above take effect via daemon-reload anyway.
      restartIfChanged = false;
      startLimitIntervalSec = 300;
      startLimitBurst = 5;
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        PAMName = "login";
        TTYPath = "/dev/tty1";
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
        StandardInput = "tty";
        StandardOutput = "journal";
        StandardError = "journal";
        ExecStart = "${lib.getExe config.programs.uwsm.package} start -- default";
        Restart = "always";
      };
    };
  };
}
