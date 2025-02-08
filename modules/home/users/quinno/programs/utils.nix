{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.cm.home.users.quinno.programs.utils;
in
{
  options.cm.home.users.quinno.programs.utils = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      age
      sops
      zed-editor
      nil
      wireguard-tools
      nvd
      nix-output-monitor
      p7zip
      unzip
      xz
    ];
    programs = {
      eza = {
        # ls Replacement
        enable = true;
        git = true;
        icons = "auto";
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
