{ pkgs, ... }:
{
  boot = {
    initrd.availableKernelModules = [
      "hid-generic"
      "nvme"
      "sd_mod"
      "thunderbolt"
      "usb_storage"
      "usbhid"
      "xhci_pci"
    ];
    kernelModules = [ "kvm-amd" ];

    kernelPackages = pkgs.linuxPackages_cachyos-server;
    supportedFilesystems = [ "bcachefs" ];

  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    graphics.enable = true;
    enableRedistributableFirmware = true;
  };
  system.stateVersion = "24.11";
}
