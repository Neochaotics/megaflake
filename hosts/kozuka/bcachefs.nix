{
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/disk/by-id/";
        content = {
          type = "gpt";
          partitions = {
            nvme0p1 = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };

            nvme0p2 = {
              size = "100%";
              content = {
                type = "bcachefs";
                filesystem = "master";
                label = "nvme0";
                extraFormatArgs = ["--discard"];
              };
            };
          };
        };
      };

      nvme1 = {
        type = "disk";
        device = "/dev/disk/by-id/";
        content = {
          type = "bcachefs";
          filesystem = "master";
          label = "nvme1";
          extraFormatArgs = ["--discard"];
        };
      };

      bcachefs_filesystems = {
        master = {
          type = "bcachefs_filesystem";
          extraFormatArgs = [
            "--compression=zstd"
            "--background_compression=ztsd"
          ];
          subvolumes = {
            nix = {
              mountpoint = "/nix";
            };
            root = {
              mountpoint = "/nix/persist";
            };
            home = {
              mountpoint = "/nix/persist/home";
            };
          };
        };

        np1 = {
          type = "bcachefs_filesystem";
          extraFormatArgs = [
            "--compression zstd:1"
            "--erasure_code"
            "--data_replicas 1"
            "--metadata_replicas 2"
          ];
          subvolumes = {
            root = {
              mountpoint = "/nix/persist/npool";
            };
          };
        };

        dp1 = {
          type = "bcachefs_filesystem";
          extraFormatArgs = [
            "--compression zstd:10"
            "--replicas 2"
          ];
          subvolumes = {
            root = {
              mountpoint = "/nix/persist/dpool";
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
  };
}
