{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.cm.nixos.packages.nvf;
in
{

imports = [
inputs.nvf.nixosModules.default
];

  options.cm.nixos.packages.nvf = {
    enable = lib.mkEnableOption "Enables nvf";
  };

  config = lib.mkIf cfg.enable {

    programs.nvf = {
    enable = true;
    # your settings need to go into the settings attribute set
    # most settings are documented in the appendix
    settings = {
      vim.viAlias = false;
      vim.vimAlias = true;
      vim.lsp = {
        enable = true;
      };
    };
  };  
};
}
