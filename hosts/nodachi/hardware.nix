{
  config,
  pkgs,
  ...
}: {
  # ff.hardware.displays = {
  #   test = {
  #     port = "DP-2";
  #     refreshRate = 144;
  #     resWidth = 2560;
  #     resHeight = 1440;
  #     ownedWorkspaces = [ 1 ];
  #   };
  # };
  #

  boot = {
    kernelPackages = pkgs.linuxPackages_cachyos;
    extraModulePackages = with config.boot.kernelPackages; [it87];
    initrd.availableKernelModules = [
      "ahci"
      "hid-generic"
      "nvme"
      "usbhid"
      "xhci_pci"
      "sp5100_tco"
    ];
    kernelModules = ["it87"];
    extraModprobeConfig = "
    options it87 ignore_resource_conflict=1
    ";
    kernelParams = [
      "video=DP-1:2560x1440@60"
      "video=HDMI-A-2:1920x1080@60"
      "video=DP-5:1920x1080@60"
      "amd_pstate=active" # Enable active pstate for better power management
      "amd_iommu=on" # Enable IOMMU for better device isolation
      "iommu=pt" # Pass-through mode for IOMMU
      "idle=nomwait" # Improves AMD CPU power efficiency
      "pci=pcie_bus_perf" # Optimize PCIe bus performance
      "transparent_hugepage=always" # Better memory management for Zen architecture
      "amdgpu.hw_i2c=1" # Enable hardware I2C
      "nowatchdog"
      "quiet"
      "splash"
    ];
  };
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
    powertop.enable = true;
    scsiLinkPolicy = "max_performance";
  };
  services = {
    scx.enable = false;
    udev.extraRules = ''
      # CTRL Keyboard (04d8:eed2)
      SUBSYSTEM=="usb", ATTR{idVendor}=="04d8", ATTR{idProduct}=="eed2", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"

      # Razer Basilisk Ultimate Mouse (1532:0086)
      SUBSYSTEM=="usb", ATTR{idVendor}=="1532", ATTR{idProduct}=="0086", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
    '';
  };
  hardware = {
    cpu = {
      amd = {
        updateMicrocode = true;
        sev.enable = true; # Enable AMD Secure Encrypted Virtualization
      };
    };

    # AMD chipset specific features
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
      amdvlk = {
        # hahah enables graphics
        enable = true;
        support32Bit.enable = true;
      };
    };

    enableRedistributableFirmware = true;
    display = {
      edid = {
        enable = true;
      };
    };
    i2c.enable = true;

    #fancontrol = {
    #  enable = true;
    #};
  };
}
