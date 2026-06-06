{
  networking.networkmanager = {
    enable = true;
    connectionConfig."ipv6.ip6-privacy" = 2;
    ethernet.macAddress = "random";
    wifi = {
      macAddress = "random";
      scanRandMacAddress = true;
    };
  };
}
