{

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  hardware = {
    cpu.amd.updateMicrocode = true;
    graphics.enable = true;
    enableRedistributableFirmware = true;
  };
}
