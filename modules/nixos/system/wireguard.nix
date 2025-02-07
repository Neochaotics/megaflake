{
  lib,
  config,
  ...
}:
let
  cfg = config.cm.nixos.system.wireguard;
in
{
  options.cm.nixos.system.wireguard = {
    enable = lib.mkEnableOption "Enable";
  };

  config = lib.mkIf cfg.enable {
    networking.wg-quick.interfaces = {
      wg0 = {
        address = [
          "10.2.0.2/32"
        ];
        dns = [ "10.2.0.1" ];
        privateKeyFile = "/persist/wg0.key";

        peers = [
          {
            publicKey = "tHwmpVZsh4yfoA9/vWbacF6cWcXUKE9wuDP5bz66oh8=";
            allowedIPs = [ "0.0.0.0/0" ];
            endpoint = "138.199.50.107:51820";
          }
        ];
      };
    };
  };
}
