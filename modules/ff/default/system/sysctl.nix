{
  lib,
  config,
  ...
}:
let
  cfg = config.freedpom.system.sysctl;
in
{
  options.freedpom.system.sysctl = {
    cachyos = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Apply CachyOS kernel parameter optimizations for improved system responsiveness, 
        memory management, and network performance. Includes swappiness tuning, 
        pressure optimizations, and TCP enhancement settings.
        See: https://github.com/CachyOS/CachyOS-Settings
      '';
    };
  };

  config = lib.mkIf cfg.cachyos {
    boot.kernel.sysctl = {
      "vm.swappiness" = 100;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_bytes" = 268435456;
      "vm.page-cluster" = 0;
      "vm.dirty_background_bytes" = 67108864;
      "vm.dirty_writeback_centisecs" = 1500;
      "net.ipv4.tcp_ecn" = 1;
      "net.core.netdev_max_backlog" = 4096;
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.ipv4.tcp_rfc1337" = 1;
      "fs.file-max" = 2097152;
      "fs.xfs.xfssyncd_centisecs" = 10000;
    };
  };
}
