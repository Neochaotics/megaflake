{
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-CT1000BX500SSD1_2451E99B1181";
        content = {
          type = "gpt";
          partitions = {
            diskp1 = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            diskp2 = {
              size = "100%";
              content = {
                type = "bcachefs";
                filesystem = "rootfs";
                label = "nvme0";
                extraFormatArgs = [ "--discard" ];
              };
            };
          };
        };
      };
    };

    bcachefs_filesystems = {
      rootfs = {
        type = "bcachefs_filesystem";
        mountpoint = "/";
        extraFormatArgs = [
          "--background_compression=zstd:3"
        ];
      };
    };
  };
}
