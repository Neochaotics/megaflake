{ pkgs, ... }:
{
  flake.modules.nixos.utils = {
    environment.systemPackages = with pkgs; [
      nil
      nixd
      wireguard-tools
      nvd
      nix-output-monitor
      p7zip
      unzip
      xz
    ];
  };

  flake.modules.hjem.utils =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.utils;
    in
    {
      options.programs.utils = {
        enable = lib.mkEnableOption "dev utilities";
      };

      config = lib.mkIf cfg.enable {
        packages = with pkgs; [
          eza
          fzf
          zoxide
        ];
      };
    };
}
