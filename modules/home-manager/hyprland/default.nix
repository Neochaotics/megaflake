{
  lib,
  config,
  pkgs,
  inputs,
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
    ./plugins/hyprexpo.nix
  ];

  options.qm.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland configuration";
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
        };

        xwayland.enable = true;

        plugins = [
          #inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
          inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprfocus
          #inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.xtra-dispatchers
        ];
      };
    };
  };
}
