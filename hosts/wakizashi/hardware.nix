{ config, ... }:
{
  boot = {
    initrd.availableKernelModules = [
      "ochi_pci"
      "ehci_pci"
      "ahci"
      "firewire_ohci"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "sr_mod"
    ];
    kernelModules = [
      "kvm-intel"
      "wl"
    ];
    extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  };
  hardware.enableRedistributableFirmware = true;
}
