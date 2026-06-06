{
  disko.devices.disk.secondary = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-CT2000P5PSSD8_23113F244794";
    content = {
      type = "gpt";
      partitions = {
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "secondarycrypt";
            settings = {
              allowDiscards = true;
            };
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/games" = {
                  mountpoint = "/games";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/persist/home" = {
                  mountpoint = "/persist/home";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
