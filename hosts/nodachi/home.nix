{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.ff.homeModules.freedpomFlake
    inputs.qm.homeModules.qModule
  ];

  home = {
    stateVersion = "24.05";
    username = "quinno";
    homeDirectory = "/home/quinno";
    #enableNixpkgsReleaseCheck = false;
    packages = with pkgs; [
      zed-editor
      legcord
      kmon
      gping
      gitoxide
    ];
  };
  ff = {
    programs = {
      bash.enable = true;
    };
    hardware.videoPorts = {
      "DP-1" = {
        resolution = {
          width = 2560;
          height = 1440;
        };
        framerate = 180;
        vrr = 3;
        cm = "auto";
        colorDepth = 10;
        workspaces = [
          "1"
          "2"
          "3"
          "4"
        ];
      };
      "DP-5" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        framerate = 75;
        position = "auto-center-right";
        transform = 3;
        workspaces = [
          "5"
          "6"
          "7"
          "8"
        ];
      };
      "HDMI-A-2" = {
        resolution = {
          width = 3840;
          height = 2160;
        };
        scale = 2;
        position = "auto-center-left";
        workspaces = [
          "9"
          "10"
        ];
      };
    };
  };

  qm = {
    programs = {
      firefox.enable = true;
      foot.enable = true;
      git.enable = true;
      utils.enable = true;
      fuzzel.enable = true;
      media.enable = false;
      ssh.enable = true;
      aria2.enable = true;
      waybar.enable = true;
      zsh.enable = true;
      starship.enable = true;
      yazi.enable = true;
      bottom.enable = true;
      nvim.enable = true;
      mpv.enable = true;
    };
    system = {
      xdg.enable = true;
    };
    desktop.hyprland = {
      enable = true;
      idlelock.enable = true;
    };
  };
}
