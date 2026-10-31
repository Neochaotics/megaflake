{
  pkgs,
  inputs,
  ...
}:
{
  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Amber";
    hyprcursor.enable = true;
  };

  rum = {
    environment.hideWarning = true;

    programs = {
      foot = {
        enable = true;
        settings = {
          main.font = "OverpassM Nerd Font Mono:size=18";
          cursor.blink = true;
        };
      };

      fuzzel = {
        enable = true;
        settings.main = {
          dpi-aware = "no";
          prompt = "'  '";
          placeholder = "...";
          fields = "filename,keywords,generic,name";
          match-mode = "fuzzy";
          width = 60;
          lines = 6;
          anchor = "top";
          y-margin = 240;
          horizontal-pad = 30;
          vertical-pad = 12;
          inner-pad = 3;
          launch-prefix = "uwsm app --";
        };
        settings.border.width = 2;
        settings.border.radius = 6;
      };

      git = {
        enable = true;
        settings = {
          user = {
            name = "Neochaotics";
            email = "72465280+Neochaotics@users.noreply.github.com";
          };
          core.editor = "nvim";
          color = {
            diff = "auto";
            interactive = "auto";
            pager = "true";
            status = "auto";
            branch = "auto";
            ui = "true";
          };
          gpg.format = "openpgp";
          gpg.openpgp.program = "${pkgs.gnupg}/bin/gpg";
          rerere = {
            enabled = "true";
            autoupdate = "true";
          };
          rebase.autoSquash = "true";
          push.default = "upstream";
          pull.rebase = "true";
        };
      };

      yazi = {
        enable = true;
        settings = {
          manager = {
            ratio = [
              1
              3
              2
            ]; # 1/6 width for parent, 3/6 width for current, 2/6 width for preview
            sort_by = "mtime";
            sort_sensitive = false;
            sort_reverse = false;
            sort_dir_first = true;
            linemode = "size";
            show_hidden = true;
            show_symlink = true;
            scrolloff = 12;
          };
          preview = {
            wrap = "yes";
            tab_size = 2;
            max_width = 640;
            max_height = 480;
            image_filter = "lanczos3";
            image_quality = 75;
            sixel_fraction = 10;
          };
          input.cursor_blink = true;
          opener = {
            play = [
              {
                run = "mpv \"$@\"";
                orphan = true;
                for = "unix";
              }
            ];
            edit = [
              {
                run = "$EDITOR \"$@\"";
                block = true;
                for = "unix";
              }
            ];
            open = [
              {
                run = "xdg-open \"$@\"";
                desc = "Openz";
              }
            ];
          };
        };
      };

      hyprlock = {
        enable = true;
        settings = {
          general = {
            hide_cursor = true;
            ignore_empty_input = true;
          };
        };
      };

    };
  };

  desktop.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

    sunset = {
      enable = true;
      settings = {
        max-gamma = 150;

        profile = [
          {
            time = "7:30";
            identity = true;
          }
          {
            time = "21:00";
            temperature = 3700;
            gamma = 0.6;
          }
        ];
      };
    };
  };

  desktop.waybar = {
    enable = true;

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

        modules-center = [ "clock" ];

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
          format-icons.default = [
            "󰕿"
            "󰖀"
            "󰕾"
          ];
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
            active = "●";
            default = "";
            empty = "○";
            visible = "◎";
            urgent = "⚠";
            persistent = "⬡";
          };
          show-special = true;
          sort-by = "number";
          all-outputs = false;
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

  desktop.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 900;
          on-timeout = "hyprlock";
        }
        {
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
