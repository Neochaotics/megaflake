{
  disko.devices = {
    disk.nix = {
      type = "disk";
      device = "/dev/disk/by-id/REPLACE_WITH_ACTUAL_DISK_ID";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "nixcrypt";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "swap" = {
                    mountpoint = "/.swap";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                    swap.swapfile.size = "8G";
                  };
                };
              };
            };
          };
        };
      };
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "defaults"
        "size=3G"
        "mode=755"
      ];
    };
  };
  fileSystems."/nix".neededForBoot = true;
}
