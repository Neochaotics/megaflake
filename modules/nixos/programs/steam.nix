{
  lib,
  config,
  pkgs-unstable,
  ...
}:
let
  cfg = config.qm.programs.steam;
in
{
  options.qm.programs.steam = {
    enable = lib.mkEnableOption "Enable Steam with proton-ge";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      package = pkgs-unstable.steam;
      extraCompatPackages = with pkgs-unstable; [ proton-ge-bin ];
      protontricks.enable = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = false;
    };

    boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;

    security.wrappers.bwrap = {
      source = "${pkgs-unstable.bubblewrap}/bin/bwrap";
      owner = "root";
      group = "root";
      setuid = true;
      permissions = "u+rx,g+x,o+x";
    };
  };
}
