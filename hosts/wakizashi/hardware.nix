_: {
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];  # Change to kvm-amd for AMD processors
  };
  hardware.enableRedistributableFirmware = true;

  services = {
    thermald.enable = true;
    auto-cpufreq = {
      enable = true;
      settings = {
        charger = {
          governor = "performance";
          energy_performance_preference = "performance";
          energy_perf_bias = "balance_performance";
        };
        battery = {
          governor = "powersave";
          energy_performance_preference = "power";
          energy_perf_bias = "balance_power";
        };
      };
    };
  };
}

