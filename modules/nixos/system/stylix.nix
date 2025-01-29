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
      image = ../../../hosts/titan/wallpaper.png;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-hard.yaml";
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Amber";
      };
      fonts = {
        serif = {
          package = pkgs.nerd-fonts._0xproto;
          name = "0xProtoNFM";
        };

        sansSerif = config.stylix.fonts.serif;

        monospace = config.stylix.fonts.serif;

        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
