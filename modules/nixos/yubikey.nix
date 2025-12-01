{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.qm.yubikey;
in
{
  options.qm = {
    yubikey = {
      enable = lib.mkEnableOption "Enable yubikey support";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      yubioath-flutter
      yubikey-manager
      yubikey-personalization
      yubico-piv-tool
      pam_u2f
    ];
    services = {
      udev.packages = [
        pkgs.yubikey-personalization
      ];

      pcscd.enable = true;
      yubikey-agent.enable = true;
    };
    security.pam = {
      #sshAgentAuth.enable = true;
      u2f = {
        enable = true;
        #control = "requisite";
        settings = {
          cue = lib.mkForce true;
          interactive = lib.mkForce true;
          origin = "pam://u2f";
          authfile = lib.mkForce (
            pkgs.writeText "u2f-mappings" (
              lib.concatStrings [
                "quinno"
                ":0p6HaYKXcoX66uJNr6a1q1+OlXZXAPQBYR3QFtG8j9/WAajpAJFdu74P7w/q/W2iXCVNfQrSWDrn/hZs9Ngt/Q==,73Qs5oeyhtOf5+OzDHx4FuOG5cvyLxgzMdYIpEWscXNQ0p6WMpbCP3nH66+tE4qbiRXyjGQxbj8iOx9ycdow4A==,es256,+presence%"
              ]
            )
          );
        };
      };
      services = {
        login.u2fAuth = true;
        hyprlock = {
          u2fAuth = true;
          unixAuth = false;
        };
        sudo = {
          u2fAuth = true;
          #unixAuth = false;
        };
      };
    };
  };
}
