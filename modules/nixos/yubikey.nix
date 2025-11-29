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
        control = "requisite";
        settings = {
          cue = true;
          interactive = true;
          authfile = pkgs.writeText "u2f-mappings" (
            lib.concatStrings [
              "quinno"
              ":nRc24/jKDKo7e7tslz13JzPo9tKjFZDpT35gS7vPYzc6fB10mhEieLafayM7cOjInGDzFwLxbr8WFEZlSVs0/g==,+QCDrdP/ylH8XB5rnxgN7K+J5yx+MULRrtWW0nEa7epdcUwMI3G6TCdnbPuw5C5PGxtn46jgUeGyr4k7TwtKfQ==,es256,+presence%"
            ]
          );
        };
      };
      services = {
        login.u2fAuth = true;
        sudo = {
          u2fAuth = true;
          #unixAuth = false;
        };
      };
    };
  };
}
