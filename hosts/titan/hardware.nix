_:

{
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
      "video=DP-5:1920x1080@60"
      "video=HDMI-A-1:1920x1080@60"
    ];
  };
  hardware = {

    cpu.amd.updateMicrocode = true;
    graphics.enable = true;
    enableRedistributableFirmware = true;

    openrazer = {
      enable = true;
      users = [ "quinno" ];
    };
    display = {
      edid = {
        enable = true;
      };
    };
    i2c.enable = true;

  };
}
