{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "hid-generic" "nvme" "xhci_pci" "ahci" "usbhid" ];
  boot.kernelModules = [ "kvm-amd" ];
  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
}

