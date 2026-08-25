{
  config,
  pkgs,
  ...
}:
{
  hardware.facter.reportPath = ./facter.json;

  freedpom.hardware.displays = {
    "DP-2" = {
      includeKernelParams = true;
      resolution = {
        width = 2560;
        height = 1440;
      };
      framerate = 120;
      vrr = 3;
      colorProfile = "auto";
      colorDepth = 32;
      workspaces = [
        "1"
        "2"
        "3"
        "4"
      ];
    };
    "HDMI-A-1" = {
      resolution = {
        width = 1920;
        height = 1080;
      };
      framerate = 75;
      position = "auto-center-right";
      transform = 3;
      workspaces = [
        "5"
        "6"
        "7"
        "8"
      ];
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    # it87: motherboard sensor/fan chip. (ryzen-smu was removed: it loads
    # but exposes no debugfs interface on this Raphael silicon.)
    extraModulePackages = with config.boot.kernelPackages; [
      it87
    ];
    initrd.availableKernelModules = [
      "hid-generic"
      "usbhid"
    ];
    kernelModules = [ "it87" ];
    extraModprobeConfig = "
    options it87 ignore_resource_conflict=1
    ";
    kernelParams = [
      "amd_iommu=on" # Enable IOMMU for better device isolation
      "iommu=pt" # Pass-through mode for IOMMU
      "idle=nomwait" # Improves AMD CPU power efficiency
      "pci=pcie_bus_perf" # Optimize PCIe bus performance
      "transparent_hugepage=always" # Better memory management for Zen architecture
      "amdgpu.hw_i2c=1" # Enable hardware I2C
      "nowatchdog"
    ];
  };
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
    scsiLinkPolicy = "max_performance";
  };

  # In-memory compressed swap (zstd). Makes the CachyOS swappiness=170 and
  # page-cluster=0 sysctls (from freedpom's steam module) behave as intended
  # and buffers memory pressure during heavy gaming/AI loads.
  zramSwap = {
    enable = true;
    priority = 100;
  };

  boot.tmp.useZram = true;
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
        sev.enable = true; # Enable AMD Secure Encrypted Virtualization
      };
    };

    # AMD GPU features not covered by facter
    amdgpu = {
      opencl.enable = true;
      overdrive.enable = true;
    };

    display = {
      edid = {
        enable = true;
      };
    };
    i2c.enable = true;
  };
}
