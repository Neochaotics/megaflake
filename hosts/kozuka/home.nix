{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.homeManagerModules.impermanence
    inputs.ff.homeModules.freedpomFlake
    inputs.qm.homeModules.qModule
  ];

  home = {
    stateVersion = "24.05";
    username = "quinno";
    homeDirectory = "/home/quinno";
    #enableNixpkgsReleaseCheck = false;
    packages = with pkgs; [
      element-desktop
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
      "DP-5" = {
        resolution = {
          width = 1920;
          height = 1080;
        };
        position = "auto-right";
      };
      "HDMI-A-1" = {
        resolution = {
          width = 3840;
          height = 2160;
        };
        scale = 2;
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
      media.enable = true;
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
