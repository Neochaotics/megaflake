{ pkgs, ... }:
{
  flake.modules.nixos.steam = {
    programs.steam = {
      enable = true;
      package = pkgs.steam;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      protontricks.enable = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession = {
        enable = true;
        args = [
          "--adaptive-sync"
          "-r"
          "120"
        ];
      };
    };

    programs.gamescope.capSysNice = true;

    boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;
  };
}
