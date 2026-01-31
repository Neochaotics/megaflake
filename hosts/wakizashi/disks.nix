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
              size = "8G";
              content = {
                type = "swap";
                randomEncryption = true;
                priority = 100;
              };
            };

            diskp3 = {
              size = "100%";
              content = {
                type = "bcachefs";
                filesystem = "rootfs";
                label = "ssd";
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
        passwordFile = "/tmp/secret.key";
        extraFormatArgs = [
          "--compression=zstd:2"
          "--background_compression=zstd:4"
          "--data_checksum=crc64"
          "--metadata_checksum=crc64"
          "--metadata_replicas=2"
          "--data_replicas=1"
          "--wide_macs"
          "--journal_flush_delay=1000"
          "--usrquota"
          "--grpquota"
        ];
        subvolumes = {
          "subvolumes/root" = {
            mountpoint = "/";
            mountOptions = [
              "verbose"
              "discard"
              "relatime"
            ];
          };
          "subvolumes/home" = {
            mountpoint = "/home";
            mountOptions = [
              "discard"
              "relatime"
            ];
          };
          "subvolumes/nix" = {
            mountpoint = "/nix";
            mountOptions = [
              "discard"
              "relatime"
            ];
          };
          "subvolumes/nix/os" = {
          };
        };
      };
    };
  };
}
