{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qm.programs.steam;
in
{
  options.qm.programs.steam = {
    enable = lib.mkEnableOption "Enable Steam gaming configuration with proton-ge, gamescope, mangohud and gamemode";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-unwrapped"
      ];
    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
      extraPackages = with pkgs; [
        gamescope
        mangohud
        gamemode
        mesa
        protonup-qt
      ];
      protontricks.enable = true;
      gamescopeSession = {
        enable = true;
      };
    };
  };
}
