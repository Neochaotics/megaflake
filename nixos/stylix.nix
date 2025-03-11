{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qm.stylix;
in
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  options.qm.stylix = {
    enable = lib.mkEnableOption "Enable stylix";
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/AngelJumbo/gruvbox-wallpapers/refs/heads/main/wallpapers/minimalistic/war-in-space.png";
        sha256 = "Ur2HybgIrLUDz9GZPigPOgjhEYNK/DymbNKBRWwT6GE=";
      };
      imageScalingMode = "fit";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-hard.yaml";
      opacity = {
        applications = 0.95;
        desktop = 0.9;
        popups = 0.9;
        terminal = 0.9;
      };
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Amber";
      };
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts._0xproto;
          name = "0xProto Nerd Font Mono";
        };

        serif = {
          package = pkgs.nerd-fonts._0xproto;
          name = "0xProto Nerd Font Propo";
        };

        sansSerif = config.stylix.fonts.serif;

        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 14;
          desktop = 12;
          popups = 14;
          terminal = 16;
        };
      };
      targets = {
        firefox = {
          colorTheme.enable = true;
          firefoxGnomeTheme.enable = true;
          profileNames = [ "default" ];
        };
        hyprland = {
          hyprpaper.enable = true;
        };
      };
    };
  };
}
