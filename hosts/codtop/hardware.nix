_: {
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "atkbd"
      "i8042"
    ];
    kernelModules = [ "kvm-intel" ];
  };
  hardware.enableRedistributableFirmware = true;
  hardware.nvidia.open = true;
}
