_: {
  programs.nvf.settings.vim.autocomplete.blink-cmp = {
    enable = true;

    friendly-snippets.enable = true;

    setupOpts = {
      completion = {
        menu.auto_show = true;
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 200;
        };
      };

      fuzzy = {
        implementation = "prefer_rust";
      };

      sources = {
        default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
          "spell"
          "ripgrep"
        ];

        # Configure providers
        providers = {
        };
      };

      # Configure key mappings
      keymap = {
        preset = "none";
        "<CR>" = [ "confirm" ];
        "<Tab>" = [ "select_next_or_confirm" ];
        "<S-Tab>" = [ "select_prev" ];
        "<C-Space>" = [ "complete" ];
        "<C-e>" = [ "close" ];
        "<C-u>" = [ "scroll_docs_up" ];
        "<C-d>" = [ "scroll_docs_down" ];
        "<C-n>" = [ "select_next" ];
        "<C-p>" = [ "select_prev" ];
      };

      cmdline = {
        sources = [
          "path"
          "cmdline"
        ];
        keymap = {
          preset = "none";
        };
      };
    };

    # Configure built-in source plugins
    sourcePlugins = {
      ripgrep = {
        enable = true;
        package = "blink-ripgrep-nvim";
        module = "blink-ripgrep";
      };

      spell = {
        enable = true;
        package = "blink-cmp-spell";
        module = "blink-cmp-spell";
      };
    };
  };
}
