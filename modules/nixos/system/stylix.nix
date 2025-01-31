{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.cm.nixos.system.stylix;
in
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  options.cm.nixos.system.stylix = {
    enable = lib.mkEnableOption "Enable stylix";
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      image = ../../../hosts/titan/wallpaper.png;
      imageScalingMode = "fit";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-hard.yaml";
      opacity = {
        applications = 1.0;
        desktop = 0.8;
        popups = 0.8;
        terminal = 0.8;
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
      };
    };
  };
}
