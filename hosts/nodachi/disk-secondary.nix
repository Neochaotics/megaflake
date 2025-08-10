{
  disko.devices.disk.secondary = {
    #sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ~/megaflake/hosts/titan/disk-secondary.nix
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
            #passwordFile = "/tmp/secondary.key";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
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
