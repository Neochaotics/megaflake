{ pkgs, ... }:
let
  blink-cmp-avante = pkgs.vimUtils.buildVimPlugin {
    pname = "blink-cmp-avante";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      owner = "Kaiser-Yang";
      repo = "blink-cmp-avante";
      rev = "master";
      sha256 = "sha256-erYg/oTS5iq83XjGck/JQCPrFCylly/8ZwFGTjICXzk=";
    };
  };
in
{
  programs.nvf.settings.vim = {
    autopairs.nvim-autopairs.enable = true;
    autocomplete.blink-cmp = {
      enable = true;

      friendly-snippets.enable = true;

      mappings = {
        complete = "<C-Space>";
        confirm = "<CR>";
        next = "<Tab>";
        previous = "<S-Tab>";
        close = "<C-e>";
        scrollDocsUp = "<C-u>";
        scrollDocsDown = "<C-d>";
      };

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
            "avante"
            "conventional-commits"
            "dictionary"
            "git"
          ];

          providers = {
            avante = {
              module = "blink-cmp-avante";
            };
          };
        };

        keymap = {
          preset = "none";
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

        avante = {
          enable = true;
          package = blink-cmp-avante;
          module = "blink-cmp-avante";
        };
      };
    };
  };

}
