{ pkgs, ... }:
{
  boot = {
    #kernelPackages = pkgs.linuxPackages_cachyos_lts;
    initrd.availableKernelModules = [
      "ehci_pci"
      "xhci_pci"
      "ohci_pci"
      "ahci"
      "firewire_ohci"
      "usb_storage"
      "usbhid"
      "hid-generic"
      "hid_apple"
      "sd_mod"
      "sr_mod"
    ];
    kernelModules = [
      "kvm-intel"
      "wl"
    ];
    blacklistedKernelModules = [ "nvidia" ];
    kernelParams = [
      "video=LVDS-1:1280x800@60"
    ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.b43Firmware_5_1_138 ];
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
