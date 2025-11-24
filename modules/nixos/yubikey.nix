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
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs)
        yubioath-flutter
        yubikey-manager

        pam_u2f
        ;
    };

    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];

    services.yubikey-agent.enable = true;
    security.pam = {
      sshAgentAuth.enable = true;
      #u2f = {
      #  enable = true;
      #  settings = {
      #    cue = true; # Tells user they need to press the button
      #    authFile = "${homeDirectory}/.config/Yubico/u2f_keys";
      #  };
      #};
      services = {
        login.u2fAuth = true;
        sudo = {
          u2fAuth = true;
          sshAgentAuth = true;
        };
      };
    };
  };
}
