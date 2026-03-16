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
      image = ./vista-gruvbox.jxl;
      imageScalingMode = "fit";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-hard.yaml";
      opacity = {
        applications = 0.95;
        desktop = 0.9;
        popups = 0.9;
        terminal = 0.9;
      };
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.overpass;
          name = "Overpass Nerd Font Mono";
        };

        serif = {
          package = pkgs.nerd-fonts.noto;
          name = "Noto Sans Nerd Font";
        };

        sansSerif = {
          package = pkgs.nerd-fonts.noto;
          name = "Noto Sans Nerd Font";
        };

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 14;
          desktop = 12;
          popups = 14;
          terminal = 16;
        };
      };
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Amber";
        size = 28;
      };
    };
  };
}
