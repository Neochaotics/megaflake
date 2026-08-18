{ pkgs, ... }:
let
  toml = pkgs.formats.toml { };
in
{
  flake.modules.hjem.yazi =
    { config, lib, ... }:
    let
      cfg = config.programs.yazi;
    in
    {
      options.programs.yazi = {
        enable = lib.mkEnableOption "yazi file manager";
        settings = lib.mkOption {
          inherit (toml) type;
          default = { };
        };
      };

      config = lib.mkIf cfg.enable {
        xdg.config.files."yazi/yazi.toml" = lib.mkIf (cfg.settings != { }) {
          source = toml.generate "yazi.toml" cfg.settings;
        };
      };
    };
}
