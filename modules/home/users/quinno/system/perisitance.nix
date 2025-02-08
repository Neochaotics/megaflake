{
  lib,
  config,
  ...
}:
let
  cfg = config.cm.home.users.quinno.system.persistence;
in
{
  options.cm.home.users.quinno.system.persistence = {
    enable = lib.mkEnableOption "Enable persistence configuration for quinno user";
  };

  config = lib.mkIf cfg.enable {
    home.persistence = {
      "/persist/home" = {
        directories = [
          "Downloads"
          "Music"
          "Pictures"
          "Documents"
          "Videos"
          ".gnupg"
          ".ssh"
          ".local/share/keyrings"
          ".local/share/direnv"
        ];
      };
      "/games" = {
        directories = [
          {
            directory = ".local/share/Steam";
            method = "symlink";
          }
        ];
      };
    };
  };
}
