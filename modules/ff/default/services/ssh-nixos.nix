{
  lib,
  config,
  ...
}:
let
  cfg = config.freedpom.services.ssh;
in
{
  options.freedpom.services.ssh = {
    enable = lib.mkEnableOption "OpenSSH server and client configuration";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      hostKeys = [
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          rounds = 100;
          type = "ed25519";
        }
      ];
    };
  };
}
