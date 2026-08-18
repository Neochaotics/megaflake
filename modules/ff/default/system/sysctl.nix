{
  ...
}:
{
  boot.kernel.sysctl = {
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_writeback_centisecs" = 1500;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "net.ipv4.tcp_ecn" = 1;
    "net.core.netdev_max_backlog" = 4096;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_rfc1337" = 1;
    "net.core.rmem_max" = 4194304;
    "net.core.wmem_max" = 4194304;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
  };
}
