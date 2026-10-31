{
  lib,
  pkgs-stable,
  ...
}:
let
  username = "quinno";
in
{
  services = {
    fluxcast.enable = true;

    # uwsm default session on tty1 (PAM autologin, replaces the getty there).
    uwsm-session = {
      enable = true;
      user = username;
    };

    tailscale = {
      enable = lib.mkForce false;
      package = pkgs-stable.tailscale;
    };

    netbird = {
      enable = true;
      ui.enable = true;
    };
  };
}
