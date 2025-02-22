{ lib, config, ... }:
let
  cfg = config.qm.system.persistence;
in
{
  options.qm.system.persistence = {
    enable = lib.mkEnableOption "Enable home persistence";
  };

  config = lib.mkIf cfg.enable {
    home.persistence."/persistent/home/${config.home.username}" = {
      directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        ".gnupg"
        ".ssh"
        ".local/share/keyrings"
      ];
      allowOther = true;
    };
  };
}
