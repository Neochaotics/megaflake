_: {
  programs.nvf.settings.vim = {
    autocomplete = {
      enableSharedCmpSources = false;

      blink-cmp = {
        enable = true;

        friendly-snippets.enable = true;

        mappings = {
          close = "<C-e>";
          complete = "<C-Space>";
          confirm = "<CR>";
          next = "<Tab>";
          previous = "<S-Tab>";
          scrollDocsDown = "<C-f>";
          scrollDocsUp = "<C-d>";
        };

        setupOpts = {
          cmdline = {
            keymap.preset = "none";
            sources = null;
          };
          completion = {
            documentation.auto_show = true;
            documentation.auto_show_delay_ms = 200;
            menu.auto_show = true;
          };
          fuzzy.implementation = "prefer_rust";
          keymap.preset = "none";
          sources = {
            default = [
              "lsp"
              "path"
              "snippets"
              "buffer"
            ];
            providers = {};
          };
        };

        sourcePlugins = {
          emoji = {
            enable = false;
            package = "blink-emoji-nvim";
            module = "blink-emoji";
          };
          ripgrep = {
            enable = false;
            package = "blink-ripgrep-nvim";
            module = "blink-ripgrep";
          };
          spell = {
            enable = false;
            package = "blink-cmp-spell";
            module = "blink-cmp-spell";
          };
        };
      };
    };
    autopairs = {
      nvim-autopairs = {
        enable = true;
        setupOpts = {};
      };
    };
  };
}
