{
  disko.devices = {
    disk.nix = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-KINGSTON_OM8PCP3512F-AI1_50026B768407BAF3";
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

    disk.home = {
      type = "disk";
      device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_1TB_S599NJ0N339115R";
      content = {
        type = "luks";
        name = "homecrypt";
        settings.allowDiscards = true;
        # initrdUnlock = false; # don't unlock at boot
        content = {
          type = "btrfs";
          extraArgs = [ "-f" ];
          subvolumes = {
            "home" = {
              mountpoint = "/nix/persist/home/codman";
              mountOptions = [
                "compress-force=zstd:1"
                "noatime"
              ];
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
