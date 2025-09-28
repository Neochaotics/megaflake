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
        framerate = 144;
      };
      "DP-5" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        position = "auto-right";
      };
      "HDMI-A-2" = {
        resolution = {
          width = 3840;
          height = 2160;
        };
        scale = 2;
        position = "auto-left";
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
