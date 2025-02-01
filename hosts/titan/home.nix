{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../../modules/home/users/quinno
    inputs.impermanence.homeManagerModules.impermanence
    inputs.sops-nix.homeManagerModules.sops
  ];

  home = {
    stateVersion = "24.05";
    username = "quinno";
    homeDirectory = "/home/quinno";
  };

  cm.home.users = {
    quinno = {
      programs = {
        firefox.enable = true;
        foot.enable = true;
        git.enable = true;
        utils.enable = true;
        fuzzel.enable = true;
        media.enable = true;
        ssh.enable = true;
      };
      system = {
        bash.enable = true;
        #persistence.enable = true;
        xdg.enable = true;
      };
      desktop.hyprland.enable = true;
    };
  };

  home.packages = with pkgs; [
    vesktop
  ];
}
