{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.qm.programs.steam;
in {
  options.qm.programs.steam = {
    enable = lib.mkEnableOption "Enable Steam gaming configuration with proton-ge, gamescope, mangohud and gamemode";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "steam"
        "steam-unwrapped"
      ];
    programs = {
      gamescope = {
        enable = true;
        capSysNice = true;
      };
      gamemode = {
        enable = true;
        enableRenice = false; # handled by ananicy
      };
      steam = {
        enable = true;
        extraCompatPackages = with pkgs; [proton-ge-bin];
        protontricks.enable = true;
        gamescopeSession = {
          enable = true;
          args = [
            "-b"
            "-W 2560"
            "-H 1440"
            "-r 144"
            "--hdr-enabled"
            "-O DP-2"
          ];
        };
        extraPackages = with pkgs; [
          mangohud
          gamemode
        ];
      };
    };

    # Configure mangohud system-wide
    environment.sessionVariables = {
      MANGOHUD = "1";
      MANGOHUD_CONFIG = "cpu_temp,gpu_temp,gpu_core_clock,gpu_mem_clock,fps,frametime,vram,ram";
    };
  };
}
