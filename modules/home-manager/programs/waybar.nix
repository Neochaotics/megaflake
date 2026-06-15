{
  lib,
  config,
  osConfig,
  ...
}:
let
  cfg = config.qm.programs.waybar;

  persistentWorkspaces = lib.filterAttrs (_: workspaces: workspaces != [ ]) (
    lib.mapAttrs (_: cfg: cfg.workspaces) osConfig.freedpom.hardware.displays
  );
in
{
  options.qm.programs.waybar = {
    enable = lib.mkEnableOption "Enable waybar with custom workspace mapping";
  };

  config = lib.mkIf cfg.enable {
    stylix.targets.waybar.enable = lib.mkForce false;

    programs.waybar = {
      enable = true;
      systemd.enable = true;

      style = ''
        * {
          border: none;
          border-radius: 0;
          min-height: 0;
          font-family: "Overpass Nerd Font Mono";
          font-size: 12px;
          font-weight: bold;
        }
        window#waybar {
          background: #282828;
          border-bottom: 1px solid #3c3836;
          color: #ebdbb2;
        }
        .modules-right > widget {
          padding: 0 3px;
          min-width: 38px;
        }
        #workspaces button {
          padding: 0 4px;
          min-width: 20px;
          background: transparent;
          color: #a89984;
          border: 1px solid #3c3836;
        }
        #workspaces button.active {
          background: transparent;
          border-color: #fabd2f;
        }
        #workspaces button.visible {
          background: rgba(131,165,152,0.3);
          box-shadow: inset 0 -2px #83a598;
        }
        #workspaces button.urgent {
          background: rgba(251,73,52,0.3);
          box-shadow: inset 0 -2px #fb4934;
        }
        #workspaces button.persistent {
          background: rgba(211,134,155,0.3);
          box-shadow: inset 0 -2px #d3869b;
        }
        #windowcount { color: #ebdbb2; }
        #cpu { color: #d79921; }
        #memory { color: #b16286; }
        #battery { color: #8ec07c; }
        #wireplumber { color: #8be9fd; }
        #network { color: #b8bb26; }
        #clock { color: #fabd2f; }
        #idle_inhibitor.activated { color: #fabd2f; }
        tooltip {
          background: #282828;
          border: 1px solid #fabd2f;
          padding: 5px 8px;
          color: #ebdbb2;
        }
      '';

      settings = [
        {
          height = 22;
          layer = "top";
          position = "top";
          spacing = 1;

          modules-left = [
            "hyprland/workspaces"
            "hyprland/windowcount"
            "hyprland/window"
          ];

          modules-center = [
            "clock"
          ];

          modules-right = [
            "idle_inhibitor"
            "cpu"
            "memory"
            "wireplumber"
            "network"
            "battery"
            "tray"
          ];

          clock = {
            format = "{:%a %d %b %H:%M:%S}";
            tooltip-format = "{calendar}";
            interval = 1;
            calendar = {
              mode = "month";
              weeks-pos = "right";
              format = {
                months = "<span color='#fabd2f'><b>{}</b></span>";
                days = "<span color='#ebdbb2'>{}</span>";
                weekdays = "<span color='#f5a97f'>{}</span>";
                today = "<span color='#fabd2f'><b><u>{}</u></b></span>";
              };
            };
            actions = {
              on-click-right = "mode";
              on-scroll-up = "shift_up";
              on-scroll-down = "shift_down";
            };
          };

          battery = {
            format = "{icon}{capacity}%";
            format-icons = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            states = {
              warning = 30;
              critical = 15;
            };
          };

          cpu = {
            format = "󰻠 {usage}%";
            interval = 10;
          };

          memory = {
            format = "󰍛 {percentage}%";
            interval = 30;
          };

          wireplumber = {
            format = "{icon}{volume}%";
            format-muted = "󰝟";
            format-icons = {
              default = [
                "󰕿"
                "󰖀"
                "󰕾"
              ];
            };
            on-click = "pavucontrol";
          };

          network = {
            format-wifi = "󰖩 {bandwidthDownBits}";
            format-ethernet = "󰈁 {bandwidthDownBits}";
            format-disconnected = "󰈂";
            tooltip-format = ''
              󰩟 {ipaddr}
              󰭴 {ifname}
            '';
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "󰅶";
              deactivated = "󰾪";
            };
            tooltip-format = "Idle: {status}";
          };
          tray = {
            icon-size = 14;
            spacing = 4;
          };

          "hyprland/workspaces" = {
            format = "<sup>{icon}</sup>{windows}";
            format-window-separator = " ";
            format-icons = {
              "1" = "一";
              "2" = "二";
              "3" = "三";
              "4" = "四";
              "5" = "五";
              "6" = "六";
              "7" = "七";
              "8" = "八";
              "9" = "九";
              "10" = "十";
              "active" = "●";
              "default" = "";
              "empty" = "○";
              "visible" = "◎";
              "urgent" = "⚠";
              "persistent" = "⬡";
            };
            show-special = true;
            sort-by = "number";
            all-outputs = false;
            "persistent-workspaces" = persistentWorkspaces;
            window-rewrite = {
              "class<firefox>" = "󰈹";
              "class<foot>" = "";
              "class<dev.zed.Zed>" = "";
              "class<com.stremio.stremio>" = "";
              "class<chromium-browser>" = "󰊯";
              "class<steam>" = "󰓓";
              "class<legcord>" = "";
            };
            window-rewrite-default = "";
            on-scroll-up = "workspace e+1";
            on-scroll-down = "workspace e-1";
          };

          "hyprland/window" = {
            separate-outputs = true;
            icon = false;
            format = " {title}";
            max-length = 60;
            all-outputs = false;
          };

          "hyprland/windowcount" = {
            format = "[{}]";
            format-empty = "[0]";
            separate-outputs = true;
          };
        }
      ];
    };
  };
}
