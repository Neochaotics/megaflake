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
    ./default.nix
  ];

  options.qm.programs.nvim = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.nvf = {
      enable = true;

      defaultEditor = true;
      enableManpages = true;

      settings = {
        vim = {

          package = pkgs.neovim-unwrapped;

          viAlias = true;
          vimAlias = true;

          withNodeJs = false;
          withPython3 = false;
          withRuby = false;

          preventJunkFiles = true;
          useSystemClipboard = true;
          spellcheck = {
            enable = true;
            languages = [ "en" ];
          };

          enableLuaLoader = true;
          enableEditorconfig = true;

          debugMode = {
            enable = false;
            logFile = "/tmp/nvim.log";
          };

          lazy = {
            plugins = {
              "avante.nvim" = {
                package = pkgs.vimPlugins.avante-nvim;
                lazy = true;
                before = ''
                  require("avante_lib").load()
                '';
                setupModule = "avante";
                setupOpts = {
                  provider = "ollama";
                  ollama = {
                    endpoint = "http://localhost:11434/";
                    model = "qwen2.5-coder:32b";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
