{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.qm.programs.utils;
in {
  options.qm.programs.utils = {
    enable = lib.mkEnableOption "Enable configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nil
      nixd
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
