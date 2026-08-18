{ pkgs, ... }:
let
  ini = pkgs.formats.ini { };
in
{
  flake.modules.nixos.fuzzel = {
    environment.systemPackages = [ pkgs.fuzzel ];
  };

  flake.modules.hjem.fuzzel =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.fuzzel;
    in
    {
      options.programs.fuzzel = {
        enable = lib.mkEnableOption "fuzzel launcher";
        settings = lib.mkOption {
          inherit (ini) type;
          default = { };
        };
      };

      config = lib.mkIf cfg.enable {
        packages = [ pkgs.fuzzel ];

        xdg.config.files."fuzzel/fuzzel.ini" = lib.mkIf (cfg.settings != { }) {
          source = ini.generate "fuzzel.ini" cfg.settings;
        };
      };
    };
}
