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
    programs = {
      gamescope = {
        enable = true;
        capSysNice = true;
      };
      steam = {
        enable = true;
        extraCompatPackages = with pkgs; [ proton-ge-bin ];
        protontricks.enable = true;
        gamescopeSession = {
          enable = true;
          args = [
            "--rt"
            "-b"
            "-W 2560"
            "-H 1440"
            "-r 144"
            "--adaptive-sync"
          ];
        };
      };
    };
  };
}
