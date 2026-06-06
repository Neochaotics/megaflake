{
  lib,
  config,
  ...
}:
let
  cfg = config.qm.desktop.hypr.land;
in
{
  imports = [
    ./general.nix
    ./appearance.nix
    ./input.nix
    ./misc.nix
    ./env.nix

    ./bindings.nix
    ./windowrules.nix

    ./ecosystem/hyprsunset.nix
    ./ecosystem/idle-lock.nix
  ];

  options.qm.desktop.hypr.land = {
    enable = lib.mkEnableOption "Enable Hyprland configuration";
  };

  config = lib.mkIf cfg.enable {
    wayland = {
      windowManager.hyprland = {
        configType = "hyprlang";
        plugins = [
          #inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
          #inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprfocus
          #inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.xtra-dispatchers
        ];
      };
    };
  };
}
