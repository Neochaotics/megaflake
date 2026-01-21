{
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-CT1000P310SSD8_24474C4BCC70";
        content = {
          type = "gpt";
          partitions = {
            nvme0p1 = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            nvme0p2 = {
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
      nvme1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-CT1000P310SSD8_24474C4BCD55";
        content = {
          type = "bcachefs";
          filesystem = "persist";
          label = "nvme1";
          extraFormatArgs = [ "--discard" ];
        };
      };
    };

    bcachefs_filesystems = {
      rootfs = {
        type = "bcachefs_filesystem";
        mountpoint = "/nix";
        extraFormatArgs = [
          "--background_compression=zstd:3"
        ];
      };
      persist = {
        type = "bcachefs_filesystem";
        subvolumes = {
          persist = {
            mountpoint = "/nix/persist";
          };
          home = {
            mountpoint = "/nix/persist/home";
          };
        };
      };
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "defaults"
        "size=6G"
        "mode=755"
      ];
    };
  };
}
