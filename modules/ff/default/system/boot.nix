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
  };

  config = lib.mkIf cfg.enable {
    boot = {
      loader.grub.enable = lib.mkForce false;
      plymouth.enable = false;

      loader.systemd-boot = {
        enable = true;
        editor = false;
        consoleMode = "auto";
        graceful = lib.mkDefault true;
        configurationLimit = 5;
      };

      kernelParams = [
        "quiet"
        "loglevel=3"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
        "systemd.show_status=auto"
      ];
      consoleLogLevel = lib.mkForce 0;
      initrd = {
        includeDefaultModules = lib.mkDefault false;
        systemd.enable = true;
      };
    };
  };
}
