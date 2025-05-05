{ lib, config, inputs, pkgs, ... }:
let
  cfg = config.qm.programs.nvim;
in
{

  imports = [ inputs.nvf.homeManagerModules.default ];

  options.qm.programs.nvim = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {
      programs.nvf = {
        enable = true;
        settings = {
        vim = {
          viAlias = false;
          vimAlias = true;

          lazy = {
            plugins = {
              "avante.nvim" = {
                package = pkgs.vimPlugins.avante-nvim;
                lazy = true;
                before = ''
                  require("avante_lib").load()
                '';
                setupModule = "avante";
              };
            };
          };
        };
        };
      };
  };
}
