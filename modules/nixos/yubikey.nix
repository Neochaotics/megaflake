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
    programs.ssh = {
      startAgent = false;
      askPassword = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
      enableAskPassword = true;
    };
    environment.systemPackages = with pkgs; [
      yubioath-flutter
      yubikey-manager
      yubikey-personalization
      yubico-piv-tool
      pam_u2f
      x11_ssh_askpass
    ];
    environment.variables = {
      SSH_ASKPASS = "${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass";
    };
    services = {
      udev.packages = [
        pkgs.yubikey-personalization
      ];

      pcscd.enable = true;
      yubikey-agent.enable = false;
    };
    security.pam = {
      sshAgentAuth = {
        enable = false;
        authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/quinno" ];
      };

      u2f = {
        enable = false;
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
      rssh = {
        enable = true;
        settings = {
          auth_key_file = "/etc/ssh/authorized_keys.d/\${user}";
          cue = true;
          loglevel = "trace";
          #authorized_keys_command = "/run/current-system/sw/bin/cat /etc/ssh/authorized_keys.d/$USER";
        };
      };
      services = {
        login.rssh = true;
        hyprlock = {
          rssh = true;
          unixAuth = false;
        };
        sudo = {
          rssh = true;
          #unixAuth = false;
        };
      };
    };
  };
}
