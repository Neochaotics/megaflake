{
  disko.devices = {
    disk = {
      nvme1 = {
        type = "disk";
        device = "/dev/nvme0n1";
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
      nvme2 = {
        type = "disk";
        device = "/dev/nvme1n1";
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
        #mountpoint = "none";
        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot@blank$' || zfs snapshot zroot@blank";

        datasets = {
          crypt = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              #keylocation = "file://" + "${config.age.secrets.crypt.path}";
            };
          };
          "crypt/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          "crypt/nix/persist" = {
            type = "zfs_fs";
            mountpoint = "/nix/persist";
          };
          "crypt/nix/persist/home/quinno" = {
            type = "zfs_fs";
            mountpoint = "/nix/persist/home/quinno";
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=3G"
          "mode=755"
        ];
      };
      "/home/quinno" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=6G"
          "uid=1000"
          "gid=1000"
          "mode=755"
        ];
      };
    };
  };
  fileSystems."/nix/persist".neededForBoot = true;
}
