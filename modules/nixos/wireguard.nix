{
  lib,
  config,
  ...
}: let
  cfg = config.qm.wireguard;
in {
  options.qm.wireguard = {
    enable = lib.mkEnableOption "Enable";
  };

  config = lib.mkIf cfg.enable {
    networking.wg-quick.interfaces = {
      #wg0 = {
      #  address = ["10.2.0.2/32"];
      #  dns = ["10.2.0.1"];
      #  privateKeyFile = "/persist/wg0.key";

      #  peers = [
      #    {
      #      publicKey = "tHwmpVZsh4yfoA9/vWbacF6cWcXUKE9wuDP5bz66oh8=";
      #      allowedIPs = ["0.0.0.0/0"];
      #      endpoint = "138.199.50.107:51820";
      #    }
      #  ];
      #};
      wgBM = {
        address = ["10.1.4.3/32"];
        dns = ["10.0.0.1"];
        privateKeyFile = "/persist/wgBM.key";

        peers = [
          {
            publicKey = "I3X4saZKZpipmgCrvwhr5xa8SLYAaLSGOm6Y5kzPZj8=";
            allowedIPs = ["10.1.1.0/24, 10.1.2.0/24, 10.1.4.0/24"];
            endpoint = "bigmonkey.org:51820";
          }
        ];
      };
    };
  };
}
