{
  pkgs,
  inputs,
  ...
}:
{
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
      zed-editor
      legcord
      element-desktop
      kmon
      gping
      gitoxide
      warp-terminal
      dolphin-emu
    ];
  };
  ff = {
    programs = {
      bash.enable = true;
    };
    hardware.videoPorts = {
      "DP-5".resolution = {
        width = 1600;
        height = 900;
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
