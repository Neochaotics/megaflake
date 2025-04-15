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
    ];
  };

  ff = {
    programs = {
      bash.enable = true;
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
