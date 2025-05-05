{ pkgs, ... }:
let
  blink-cmp-avante = pkgs.vimUtils.buildVimPlugin {
    pname = "blink-cmp-avante";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      owner = "Kaiser-Yang";
      repo = "blink-cmp-avante";
      rev = "master";
      sha256 = "sha256-YCBYae/hP0B7eaRf/Q9nel9RiqKV5ih1LkTdIa1hymU=";
    };
  };
  blink-cmp-dictionary = pkgs.vimUtils.buildVimPlugin {
    pname = "blink-cmp-dictionary";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      owner = "Kaiser-Yang";
      repo = "blink-cmp-dictionary";
      rev = "master";
      sha256 = "sha256-YCBYae/hP0B7eaRf/Q9nel9RiqKV5ih1LkTdIa1hymU=";
    };
  };
  blink-cmp-git = pkgs.vimUtils.buildVimPlugin {
    pname = "blink-cmp-git";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      owner = "Kaiser-Yang";
      repo = "blink-cmp-git";
      rev = "master";
      sha256 = "sha256-YCBYae/hP0B7eaRf/Q9nel9RiqKV5ih1LkTdIa1hymU=";
    };
  };
  blink-cmp-conventional-commits = pkgs.vimUtils.buildVimPlugin {
    pname = "blink-cmp-avante";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      owner = "disrupted";
      repo = "blink-cmp-conventional-commits";
      rev = "main";
      sha256 = "sha256-YCBYae/hP0B7eaRf/Q9nel9RiqKV5ih1LkTdIa1hymU=";
    };
  };
in
{
  programs.nvf.settings.vim.autocomplete.blink-cmp = {
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
          dictionary = {
            module = "blink-cmp-dictionary";
          };
          git = {
            module = "blink-cmp-git";
          };
          conventional-commits = {
            module = "blink-cmp-conventional-commits";
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

      dictionary = {
        enable = true;
        package = blink-cmp-dictionary;
        module = "blink-cmp-dictionary";
      };

      git = {
        enable = true;
        package = blink-cmp-git;
        module = "blink-cmp-git";
      };

      conventional-commits = {
        enable = true;
        package = blink-cmp-conventional-commits;
        module = "blink-cmp-conventional-commits";
      };
    };
  };
}
