{
  boot = {
    initrd.availableKernelModules = [
      "ehci_pci"
      "xhci_pci"
      "ohci_pci"
      "ahci"
      "firewire_ohci"
      "usb_storage"
      "usbhid"
      "hid-generic"
      "sd_mod"
      "sr_mod"
    ];
    kernelModules = [
      "kvm-intel"
      "wl"
    ];
    extraModulePackages = [ "config.boot.kernelPackages.broadcom_sta" ];
  };
  hardware.enableRedistributableFirmware = true;
}
