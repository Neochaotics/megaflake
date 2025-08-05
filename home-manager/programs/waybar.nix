{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.qm.programs.waybar;
in {
  options.qm.programs.waybar = {
    enable = lib.mkEnableOption "Enable ";
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      style = ''
        ${builtins.readFile "${pkgs.waybar}/etc/xdg/waybar/style.css"}

        * {
          border: none;
          border-radius: 0;
          min-height: 0;
        }

        window#waybar {
          background: transparent;
          border-bottom: none;
        }

        #clock {
          border-radius: 3px;
          margin: 6px 3px;
          padding: 3px 6px;
        }

        #workspaces button {
          all: initial;
          min-width: 0;
          box-shadow: inset 0 -3px transparent;
          padding: 3px 12px;
          margin: 6px 3px;
          border-radius: 3px;
        }
      '';
      settings = [
        {
          height = 30;
          layer = "top";
          position = "top";
          modules-left = ["hyprland/workspaces"];
          modules-center = ["hyprland/window"];
          modules-right = ["clock"];
          clock = {
            format-alt = "{:%Y-%m-%d}";
            tooltip-format = "{:%Y-%m-%d | %H:%M}";
          };
          "hyprland/workspaces" = {
            "format" = "<sup>{name}</sup>{icon}{windows}";
            "format-window-separator" = " ";
            "format-icons" = {
              "default" = "";
              "empty" = "";
            };
            "persistent-workspaces" = {
              "DP-5" = [
                5
                6
                7
                8
              ];
              "HDMI-A-1" = [
                1
                2
                3
                4
              ];
            };
            "window-rewrite-default" = "";
            "window-rewrite" = {
              "class<foot>" = "";
              "class<dev.zed.Zed>" = "";
              "class<firefox>" = "󰈹";
              "class<com.stremio.stremio>" = "";
            };
          };
          "hyprland/window" = {
            "separate-outputs" = true;
            "icon" = false;
          };
        }
      ];
    };
  };
}
