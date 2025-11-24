{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.qm.desktop.hyprland;
in
{
  imports = [
    ./general.nix
    ./appearance.nix
    ./input.nix
    ./misc.nix
    ./env.nix

    ./bindings.nix
    ./monitors.nix
    ./windowrules.nix

    ./idlelock.nix

    ./plugins/dynamic-cursors.nix
  ];

  options.qm.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable Quinn's Hyprland configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      hyprpolkitagent
      hyprland-qtutils
    ];

    # systemd.user.services.hyprland = {
    #   Unit = {
    #     Description = "Hyprland Wayland Compositor";
    #     After = [ "graphical-session-pre.target" ];
    #     Wants = [ "graphical-session-pre.target" ];
    #   };
    #   Service = {
    #     Type = "simple";

    #     ExecStart = "${inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland}/bin/Hyprland";
    #     Restart = "on-failure";
    #   };
    #   Install = {
    #     WantedBy = [ "graphical-session.target" ];
    #   };
    # };

    wayland = {
      systemd.target = "hyprland-session.target";
      windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        systemd = {
          enable = true;
          enableXdgAutostart = true;
          #variables = [ "--all" ];
        };

        xwayland.enable = true;

        #plugins = [ inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors ];
      };
    };
  };
}
