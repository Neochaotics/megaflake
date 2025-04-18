{
  ff.hardware.displays = {
    test = {
      port = "DP-2";
      refreshRate = 144;
      resWidth = 2560;
      resHeight = 1440;
      ownedWorkspaces = [ 1 ];
    };
  };

  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "amdgpu"
      "hid-generic"
      "nvme"
      "usbhid"
      "xhci_pci"
    ];
    kernelModules = [ "kvm-amd" ];
    kernelParams = [
      "video=DP-2:2560x1440@144"
      "video=DP-1:1920x1080@60"
      "video=HDMI-A-1:1920x1080@60"
    ];
  };
  hardware = {
    cpu.amd.updateMicrocode = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    enableRedistributableFirmware = true;

    # wouldnt build 04/04/2025
    #openrazer = {
    #  enable = true;
    #  users = [ "quinno" ];
    #};
    display = {
      edid = {
        enable = true;
      };
    };
    i2c.enable = true;

  };
}
