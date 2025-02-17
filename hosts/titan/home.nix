{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.impermanence.homeManagerModules.impermanence
    inputs.ff.homeManagerModules.freedpomFlake
    inputs.qm.homeManagerModules.qModule
    inputs.sops-nix.homeManagerModules.sops
  ];

  home = {
    stateVersion = "24.05";
    username = "quinno";
    homeDirectory = "/home/quinno";
    #enableNixpkgsReleaseCheck = false;
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
    };
    system = {
      xdg.enable = true;
    };
    desktop.hyprland = {
      enable = true;
      idlelock.enable = true;
    };
  };

  home.packages = with pkgs; [ vesktop ];
}
