{ pkgs, ... }:
let
  json = pkgs.formats.json { };
in
{
  flake.modules.nixos.waybar = {
    programs.waybar.enable = true;
  };

  flake.modules.hjem.waybar =
    { config, lib, ... }:
    let
      cfg = config.programs.waybar;
    in
    {
      options.programs.waybar = {
        enable = lib.mkEnableOption "waybar status bar";
        style = lib.mkOption {
          type = lib.types.lines;
          default = "";
        };
        settings = lib.mkOption {
          type = lib.types.listOf json.type;
          default = [ ];
        };
      };

      config = lib.mkIf cfg.enable {
        packages = [ pkgs.waybar ];

        xdg.config.files."waybar/style.css" = lib.mkIf (cfg.style != "") {
          text = cfg.style;
        };

        xdg.config.files."waybar/config.jsonc" = lib.mkIf (cfg.settings != [ ]) {
          source = json.generate "config.jsonc" (builtins.head cfg.settings);
        };
      };
    };
}
