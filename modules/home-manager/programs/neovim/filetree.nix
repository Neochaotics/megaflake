{pkgs, ...}: {
  programs.nvf.settings = {
    vim.filetree.nvimTree = {
      enable = true; # Default: false [1]

      # Mappings for various actions
      # All of these have a 'null or string' type and default keybindings [1, 2]
      mappings = {
        findFile = "<leader>tg"; # Default: "<leader>tg" [1]
        focus = "<leader>tf"; # Default: "<leader>tf" [1]
        refresh = "<leader>tr"; # Default: "<leader>tr" [2]
        toggle = "<leader>t"; # Default: "<leader>t" [2]
      };

      openOnSetup = true; # Default: true [2]

      # Option table to pass into the setup function of Nvim Tree
      # Type: anything
      # Default: { } [3]
      setupOpts = {
        # Configuration for various actions [3]
        actions = {
          change_dir = {
            # vim change-directory behaviour [3]
            enable = true; # Default: true [4]
            global = false; # Default: false [4]
            restrict_above_cwd = false; # Default: false [5]
          };
          expand_all = {
            # Configuration for expand_all behaviour [5]
            exclude = []; # Default: [ ".git" "target" "build" "result" ] [5]
            max_folder_discovery = 300; # Default: 300 [6]
          };
          file_popup = {
            # Configuration for file_popup behaviour [6]
            open_win_config = {
              # Floating window config for file_popup [6]
              border = "rounded";
              col = 1;
              relative = "cursor";
              row = 1;
              style = "minimal";
            };
          };
          open_file = {
            # Configuration options for opening a file from nvim-tree [7]
            eject = false; # Default: false [7]
            quit_on_open = false; # Default: false [8]
            resize_window = false; # Default: false [8]
            window_picker = {
              # window_picker [8]
              enable = false; # Default: false [9]
              chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"; # Default: "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890" [9]
              exclude = {
                # Exclude list for window picker [9, 10]
                buftype = [
                  "nofile"
                  "terminal"
                  "help"
                ]; # Default: [ "nofile" "terminal" "help" ] [10]
                filetype = [
                  "notify"
                  "packer"
                  "qf"
                  "diff"
                  "fugitive"
                  "fugitiveblame"
                ]; # Default: [ "notify" "packer" "qf" "diff" "fugitive" "fugitiveblame" ] [10]
              };
              picker = "default"; # Default: "default" [11]
            };
          };
          remove_file = {
            # remove_file behaviour [11]
            close_window = true; # Default: true [11]
          };
          use_system_clipboard = true; # Default: true [12]
        };
        auto_reload_on_write = true; # Default: true [12]
        diagnostics = {
          # Show LSP and COC diagnostics in the signcolumn [12]
          enable = false; # Default: false [13]
          debounce_delay = 50; # Default: 50 [13]
          icons = {
            # Icons for diagnostic severity [13]
            error = ""; # Default: "" [14]
            hint = ""; # Default: "" [14]
            info = ""; # Default: "" [14]
            warning = ""; # Default: "" [15]
          };
          severity = {
            # Severity for which diagnostics will be displayed [15]
            max = "ERROR"; # Default: "ERROR" [15]
            min = "HINT"; # Default: "HINT" [16]
          };
          show_on_dirs = false; # Default: false [16]
          show_on_open_dirs = true; # Default: true [17]
        };
        disable_netrw = false; # Default: false [17]
        filesystem_watchers = {
          # Use file system watcher (libuv fs_event) for changes [17]
          enable = true; # Default: true [18]
          debounce_delay = 50; # Default: 50 [18]
          ignore_dirs = []; # Default: [ ] [19]
        };
        filters = {
          # Filtering options [19]
          dotfiles = false; # Default: false [19]
          exclude = []; # Default: [ ] [20]
          git_clean = false; # Default: false [20]
          git_ignored = false; # Default: false [21]
          no_buffer = false; # Default: false [21]
        };
        git = {
          # Git integration with icons and colors [21]
          enable = false; # Default: false [21]
          disable_for_dirs = []; # Default: [ ] [22]
          show_on_dirs = true; # Default: true [22]
          show_on_open_dirs = true; # Default: true [22]
          timeout = 400; # Default: 400 [23]
        };
        hijack_cursor = false; # Default: false [23]
        hijack_directories = {
          # Enable hijack_directories feature [23]
          enable = true; # Default: true [24]
          auto_open = false; # Default: false [24]
        };
        hijack_netrw = true; # Default: true [24]
        hijack_unnamed_buffer_when_opening = false; # Default: false [25]
        live_filter = {
          # Configurations for the live_filtering feature [25]
          always_show_folders = true; # Default: true [26]
          prefix = "[FILTER]: "; # Default: "[FILTER]: " [26]
        };
        modified = {
          # Indicate which file have unsaved modification [26]
          enable = false; # Default: false [27]
          show_on_dirs = true; # Default: true [27]
          show_on_open_dirs = true; # Default: true [27]
        };
        notify = {
          # Configuration for notifications [28]
          absolute_path = true; # Default: true [28]
          threshold = "INFO"; # Default: "INFO" [28]
        };
        prefer_startup_root = false; # Default: false [29]
        reload_on_bufenter = false; # Default: false [29]
        renderer = {
          # Configuration options for rendering [29]
          add_trailing = false; # Default: false [30]
          full_name = false; # Default: false [30]
          group_empty = false; # Default: false [30]
          highlight_git = false; # Default: false [31]
          highlight_modified = "none"; # Default: "none" [32]
          highlight_opened_files = "none"; # Default: "none" [32]
          icons = {
            # Configuration options for icons [33]
            bookmarks_placement = "after"; # Default: "after" [33]
            diagnostics_placement = "after"; # Default: "after" [34]
            git_placement = "before"; # Default: "before" [34]
            glyphs = {
              # Configuration options for icon glyphs [35]
              default = ""; # Default: "" [35]
              folder = {
                # Glyphs for directories [35]
                arrow_closed = "";
                arrow_open = "";
                default = "";
                empty = "";
                empty_open = "";
                open = "";
                symlink = "";
                symlink_open = "";
              };
              git = {
                # Glyphs for git status [36]
                deleted = "";
                ignored = "◌";
                renamed = "➜";
                staged = "✓";
                unmerged = "";
                unstaged = "✗";
                untracked = "★";
              };
              modified = ""; # Default: "" [36]
              symlink = ""; # Default: "" [37]
            };
            hidden_placement = "after"; # Default: "after" [37]
            modified_placement = "after"; # Default: "after" [38]
            padding = " "; # Default: " " [38]
            show = {
              # Show icons [38]
              file = true; # Default: true [38]
              folder = true; # Default: true [39]
              folder_arrow = true; # Default: true [39]
              git = false; # Default: false [40]
              modified = true; # Default: true [40]
            };
            symlink_arrow = " ➛ "; # Default: " ➛ " [40]
            webdev_colors = true; # Default: true [41]
          };
          indent_markers = {
            # Configuration options for tree indent markers [41]
            enable = false; # Default: false [42]
            icons = {
              # Individual elements of the indent markers [42]
              bottom = "─";
              corner = "└";
              edge = "│";
              item = "│";
              none = "";
            };
            inline_arrows = true; # Default: true [42]
          };
          indent_width = 2; # Default: 2 [43]
          root_folder_label = false; # Default: false [43]
          special_files = [
            "Cargo.toml"
            "README.md"
            "readme.md"
            "Makefile"
            "MAKEFILE"
            "flake.nix"
            "cargo.toml"
          ]; # Default: [ "Cargo.toml" "README.md" "readme.md" "Makefile" "MAKEFILE" "flake.nix" "cargo.toml" ] [44]
          symlink_destination = true; # Default: true [45]
        };
        respect_buf_cwd = false; # Default: false [45]
        root_dirs = []; # Default: [ ] [45]
        select_prompts = false; # Default: false [46]
        sort = {
          # Sorting options [46]
          folders_first = true; # Default: true [46]
          sorter = "name"; # Default: "name" [47]
        };
        sync_root_with_cwd = false; # Default: false [47]
        system_open = {
          # System open command [47]
          args = []; # Default: [ ] [47]
          cmd = "${pkgs.xdg-utils}/bin/xdg-open"; # Default: "${pkgs.xdg-utils}/bin/xdg-open" [48]
        };
        tab = {
          # Configuration for tab behaviour [48]
          sync = {
            # Configuration for syncing nvim-tree across tabs [48]
            close = false; # Default: false [49]
            ignore = []; # Default: [ ] [49]
            open = false; # Default: false [50]
          };
        };
        trash = {
          # Configuration options for trashing [50]
          cmd = "${pkgs.glib}/bin/gio trash"; # Default: "${pkgs.glib}/bin/gio trash" [50]
        };
        ui = {
          # General UI configuration [51]
          confirm = {
            # Confirm before actions [51]
            remove = true; # Default: true [51]
            trash = true; # Default: true [51]
          };
        };
        update_focused_file = {
          # Update the focused file on BufEnter [52]
          enable = false; # Default: false [52]
          ignore_list = []; # Default: [ ] [53]
          update_root = false; # Default: false [53]
        };
        view = {
          # Window / buffer setup [54]
          centralize_selection = false; # Default: false [54]
          cursorline = true; # Default: true [54]
          debounce_delay = 15; # Default: 15 [55]
          float = {
            # Configuration options for floating window [55]
            enable = false; # Default: false [55]
            open_win_config = {
              # Floating window config [56]
              border = "rounded";
              col = 1;
              height = 30;
              relative = "editor";
              row = 1;
              width = 30;
            };
            quit_on_focus_loss = true; # Default: true [56]
          };
          number = false; # Default: false [57]
          preserve_window_proportions = false; # Default: false [57]
          relativenumber = false; # Default: false [58]
          side = "left"; # Default: "left" [58]
          signcolumn = "yes"; # Default: "yes" [58]
          width = 30; # Default: 30 [59]
        };
      };
    };
  };
}
