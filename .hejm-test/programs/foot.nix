{ pkgs, ... }:
let
  ini = pkgs.formats.ini { };
in
{
  flake.modules.nixos.foot = {
    environment.systemPackages = [ pkgs.foot ];
  };

  flake.modules.hjem.foot =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.foot;
    in
    {
      options.programs.foot = {
        enable = lib.mkEnableOption "foot terminal emulator";
        settings = lib.mkOption {
          inherit (ini) type;
          default = { };
        };
      };

      config = lib.mkIf cfg.enable {
        packages = [ pkgs.foot ];

        xdg.config.files."foot/foot.ini" = lib.mkIf (cfg.settings != { }) {
          source = ini.generate "foot.ini" cfg.settings;
        };
      };
    };
}
