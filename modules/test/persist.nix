{ lib, config, ... }:
let
  cfg = config.cm.nixos.system.persistence;
in
{
  options.cm.nixos.system.persistence = {
    enable = lib.mkEnableOption "System persistence for Nix";
  };

  config = lib.mkIf cfg.enable {
    environment.persistence = {
      "/persist" = {
        enable = true;
        hideMounts = true;
        directories = [
          "/var/log"
          "/var/lib/bluetooth"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/etc/NetworkManager/system-connections"
          "/etc/nixos"
          {
            directory = "/var/lib/colord";
            user = "colord";
            group = "colord";
            mode = "u=rwx,g=rx,o=";
          }
        ];
        files = [
          "/etc/machine-id"
          {
            file = "/var/keys/secret_file";
            parentDirectory = {
              mode = "u=rwx,g=,o=";
            };
          }
        ];
      };
    };
  };
}
