{ config, ... }:
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
    # extraModulePackages = [
    #   (config.boot.kernelPackages.broadcom_sta.overrideAttrs (old: {
    #     patches = old.patches ++ [
    #       (builtins.fetchurl {
    #         url = "https://raw.githubusercontent.com/archlinux/svntogit-community/5ec5b248976f84fcd7e3d7fae49ee91289912d12/trunk/012-linux517.patch";
    #         sha256 = "df557afdb0934ed2de6ab967a350d777cbb7b53bf0b1bdaaa7f77a53102f30ac";
    #       })
    #     ];
    #   }))
    # ];
    kernelParams = [
      "video=LVDS-1:1280x800@60"
    ];
  };
  hardware = {
    enableRedistributableFirmware = true;
    nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_340;

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
