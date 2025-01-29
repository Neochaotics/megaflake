{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.cm.home.users.quinno.programs.eza;
in
{
  options.cm.home.users.quinno.programs.utils = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      age
      sops
      stremio
      zed
      vim
    ];
    programs = {

      eza = {
        # ls Replacement
        enable = true;
        git = true;
        icons = true;
      };
      fzf = {
        # Fuzzy Finder
        enable = true;
      };
      zoxide = {
        # Directory Jumping / cd Replacement
        enable = true;
      };
    };
  };
}
