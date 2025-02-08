{ hostname, ... }:
{
  networking = {
    hostName = hostname; # Define your hostname.
    networkmanager.enable = true;
  };
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  time.timeZone = "America/New_York";

  console = {
    earlySetup = true;
    #font = "Lat2-Terminus16";
    useXkbConfig = true;
  };
}
