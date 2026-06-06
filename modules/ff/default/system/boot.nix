{
  lib,
  config,
  ...
}:
let
  cfg = config.freedpom.system.boot;
in
{
  options.freedpom.system.boot = {
    enable = lib.mkEnableOption "Modern bootloader configuration with UEFI/BIOS support";

    verbosity = lib.mkOption {
      type = lib.types.enum [
        "quiet"
        "normal"
        "verbose"
      ];
      default = "quiet";
      description = "Controls boot verbosity level: quiet, normal, or verbose.";
    };

    splash = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable graphical splash screen.";
    };

    nvme-nopower = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "When enabled, this will disable nvme APST and ACPI (power management features).";
    };

    firmware = lib.mkOption {
      type = lib.types.enum [
        "uefi"
        "bios"
      ];
      default = "uefi";
      description = "Select firmware mode: UEFI (modern) or BIOS (legacy)";
    };

    loaderEntries = lib.mkOption {
      type = lib.types.int;
      default = 9;
      description = "Maximum number of loader entries to keep.";
    };

    editor = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable boot editor.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      loader.grub.enable = lib.mkForce false;
      plymouth.enable = cfg.splash;

      loader = {
        timeout =
          if cfg.verbosity == "quiet" then
            0
          else if cfg.verbosity == "normal" then
            3
          else
            6;

        efi = lib.mkIf (cfg.firmware == "uefi") {
          efiSysMountPoint = "/boot";
          canTouchEfiVariables = true;
        };

        limine = lib.mkIf (cfg.firmware == "bios") {
          enable = true;
          enableEditor = cfg.editor;
          maxGenerations = cfg.loaderEntries;
          biosSupport = true;
        };

        systemd-boot = lib.mkIf (cfg.firmware == "uefi") {
          enable = true;
          inherit (cfg) editor;
          consoleMode = "auto";
          graceful = lib.mkDefault true;
          configurationLimit = cfg.loaderEntries;
        };
      };

      kernelParams =
        (lib.optionals (cfg.verbosity == "quiet") [
          "quiet"
          "loglevel=3"
          "rd.udev.log_level=3"
          "udev.log_priority=3"
          "systemd.show_status=auto"
        ])
        ++ (lib.optionals (cfg.verbosity == "verbose") [
          "loglevel=7"
          "systemd.show_status=1"
          "boot.shell_on_fail"
        ])
        ++ (lib.optionals cfg.splash [
          "splash"
        ])
        ++ (lib.optionals cfg.nvme-nopower [
          "nvme.noacpi=1"
          "nvme_core.default_ps_max_latency_us=0"
        ]);
      consoleLogLevel = if cfg.verbosity == "quiet" then lib.mkForce 0 else lib.mkForce 7;
      initrd = {
        includeDefaultModules = lib.mkDefault false;
        verbose = cfg.verbosity == "verbose";
        systemd.enable = true;
      };
    };
  };
}
