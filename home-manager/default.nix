{ ... }:
{
  imports = [
    ./hyprland
    ./programs
    ./system
  ];
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true; 
}
