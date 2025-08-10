_: {
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "atkbd"
      "i8042"
    ];
    kernelModules = ["kvm-intel"];
  };
  hardware.enableRedistributableFirmware = true;
  hardware.nvidia.open = true;

  services = {
    thermald.enable = true;
    auto-cpufreq = {
      enable = true;
      settings = {
        charger = {
          governor = "performance"; # performance powersave
          energy_performance_preference = "performance"; # default performance balance_performance balance_power power
          energy_perf_bias = "balance_performance"; # performance (0), balance_performance (4), default (6), balance_power (8), or power (15)
          platform_profile = "performance";
          # scaling_min_freq = 800000
          # scaling_max_freq = 1000000
          tubo = "auto"; # always, auto, never
        };
        battery = {
          governor = "powersave";
          energy_performance_preference = "power";
          energy_perf_bias = "balance_power";
          platform_profile = "low-power";
          # scaling_min_freq = 800000
          # scaling_max_freq = 1000000
          tubo = "auto";
        };
      };
    };
  };
}
