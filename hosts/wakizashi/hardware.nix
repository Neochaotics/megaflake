{ config, pkgs, ... }:
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
      "nouveau"
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
  services.xserver = {
    enable = false;
    videoDrivers = [ "nouveau" ];
  };
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.b43Firmware_5_1_138 ];
    nvidia = {
      open = true;
      modesetting.enable = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
