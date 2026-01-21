{ pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    initrd.availableKernelModules = [
      "ahci"
      "ehci_pci"
      "firewire_ohci"
      "hid-generic"
      "hid_apple"
      "ohci_pci"
      "sd_mod"
      "sr_mod"
      "usb_storage"
      "usbhid"
      "xhci_pci"
    ];
    kernelModules = [
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
