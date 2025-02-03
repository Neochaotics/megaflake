{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.cm.home.users.quinno.programs.waybar;
in
{
  options.cm.home.users.quinno.programs.waybar = {
    enable = lib.mkEnableOption "Enable ";
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      style = ''
        ${builtins.readFile "${pkgs.waybar}/etc/xdg/waybar/style.css"}

        window#waybar {
          background: transparent;
          border-bottom: none;
        }
      '';
      settings = [
        {
          height = 30;
          layer = "top";
          position = "top";
          modules-right = [
            "clock"
          ];
          clock = {
            format-alt = "{:%Y-%m-%d}";
            tooltip-format = "{:%Y-%m-%d | %H:%M}";
          };
        }
      ];
    };
  };
}
