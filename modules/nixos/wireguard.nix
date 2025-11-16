{
  lib,
  config,
  ...
}:
let
  cfg = config.qm.wireguard;
in
{
  options.qm.wireguard = {
    enable = lib.mkEnableOption "Enable";
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall.allowedUDPPorts = [ 51820 ];
      wg-quick.interfaces = lib.mkForce { };
      wireguard.interfaces = {
        wgBM = {
          ips = [ "10.1.4.3/24" ];
          listenPort = 51820;
          privateKeyFile = "/persist/wgBM.key";
          peers = [
            {
              name = "bigmonkey";
              publicKey = "I3X4saZKZpipmgCrvwhr5xa8SLYAaLSGOm6Y5kzPZj8=";
              presharedKeyFile = "/persist/wgBMpre.key";
              allowedIPs = [
                "10.1.1.0/24"
                "10.1.2.0/24"
                "10.1.4.0/24"
              ];
              endpoint = "bigmonkey.org:51820";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
  };
}
