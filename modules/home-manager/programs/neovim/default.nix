{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.qm.programs.nvim;
in
{
  imports = [
    inputs.nvf.homeManagerModules.default
    ./autocomplete.nix
    ./binds.nix
    ./comments.nix
    ./dashboard.nix
    #./debug.nix
    ./diagnostics.nix
    ./filetree.nix
  ];

  options.qm.programs.nvim = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      neovide = {
        enable = true;
      };
      nvf = {
        enable = true;

        defaultEditor = true;
        enableManpages = true;

        settings = {
          vim = {
            package = pkgs.neovim-unwrapped;

            bell = "none";
            vimAlias = true;
            withNodeJs = false;
            withPython3 = false;
            withRuby = true;
            preventJunkFiles = true;

            globals = {
              editorconfig = true;
              mapleader = " ";
              maplocalleader = ",";
            };

            options = {
              autoindent = true;
              cmdheight = 1;
              cursorlineopt = "line";
              shiftwidth = 8;
              signcolumn = "yes";
              splitbelow = true;
              tm = 500;
              updatetime = 300;
              wrap = true;
            };

            clipboard = {
              enable = false;
              providers = {
                xsel = {
                  enable = false;
                };
              };
            };

            spellcheck = {
              enable = true;
              languages = [ "en" ];
            };

            enableLuaLoader = true;

            debugMode = {
              enable = false;
              level = 16;
              logFile = "/tmp/nvim.log";
            };
          };
        };
      };
    };
  };
}
