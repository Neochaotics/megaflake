{

  boot.initrd.availableKernelModules = [
    "hid-generic"
    "nvme"
    "sd_mod"
    "thunderbolt"
    "usb_storage"
    "usbhid"
    "xhci_pci"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  hardware = {
    cpu.amd.updateMicrocode = true;
    graphics.enable = true;
    enableRedistributableFirmware = true;
  };
}
