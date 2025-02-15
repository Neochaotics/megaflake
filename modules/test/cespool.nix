{
  hostname,
  modulesPath,
  inputs,
  ...
}:
{

  networking = {
    hostName = hostname; # Define your hostname.
    hostId = "00000000"; # Define your host ID.
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

  imports = [ (modulesPath + "/profiles/minimal.nix") ];
  boot.initrd.includeDefaultModules = false;
  disabledModules = [
    (modulesPath + "/profiles/all-hardware.nix")
    (modulesPath + "/profiles/base.nix")
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bk";
    extraSpecialArgs = {
      inherit inputs;
    };
  };
}
