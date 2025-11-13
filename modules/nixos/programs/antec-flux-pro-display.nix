{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.qm.antec-display;
  antec-flux-pro-display = pkgs.callPackage ../../../packages/antec-flux-pro-display.nix {};
  antec-flux-pro-display-udev =
    pkgs.callPackage ../../../packages/antec-flux-pro-display-udev.nix
    {};

  configFileText = ''
    # CPU device for temperature monitoring
    cpu_device=${cfg.cpu.device}
    cpu_temp_type=${cfg.cpu.tempType}

    # GPU device for temperature monitoring
    gpu_device=${cfg.gpu.device}
    gpu_temp_type=${cfg.gpu.tempType}

    # Update interval in milliseconds
    update_interval=${toString cfg.updateInterval}
  '';
in {
  options.qm.antec-display = {
    enable = lib.mkEnableOption "Enable";

    cpu = {
      device = lib.mkOption {
        type = lib.types.str;
        default = "k10temp";
        description = "Name of the CPU temperature sensor device.";
      };
      tempType = lib.mkOption {
        type = lib.types.str;
        default = "tctl";
        description = "CPU temperature type (e.g. tctl, tdie, etc.).";
      };
    };

    gpu = {
      device = lib.mkOption {
        type = lib.types.str;
        default = "amdgpu";
        description = "Name of the GPU temperature sensor device.";
      };
      tempType = lib.mkOption {
        type = lib.types.str;
        default = "edge";
        description = "GPU temperature type (e.g. edge, junction, etc.).";
      };
    };

    updateInterval = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1000;
      description = "Update interval for sensor polling in milliseconds.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [antec-flux-pro-display-udev];
    environment.etc."antec-flux-pro-display/config.conf".text = configFileText;
    systemd.services.antec-flux-pro-display = {
      description = "Antec Flux Pro Display Service";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${antec-flux-pro-display}/bin/antec-flux-pro-display";
        Restart = "always";
        RestartSec = 5;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };
  };
}
