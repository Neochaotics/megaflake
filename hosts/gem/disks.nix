{
  disko.devices = {
    disk = {
      x = {
        type = "disk";
        device = "/dev/sdx";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "64M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
      y = {
        type = "disk";
        device = "/dev/sdy";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "mirror";
        # Workaround: cannot import 'zroot': I/O error in disko tests
        options.cachefile = "none";
        mountpoint = "none";
        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot@blank$' || zfs snapshot zroot@blank";

        datasets = {
          crypt = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
            };
          };
          "encrypted/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          "encrypted/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
          };
          "encrypted/persist/home" = {
            type = "zfs_fs";
            mountpoint = "/persist/home";
          };
        };
      };
    };
    root = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=5G"
          "mode=755"
        ];
      };
    };
  };
}
