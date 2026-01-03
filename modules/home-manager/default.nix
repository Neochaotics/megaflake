{ inputs, ... }:
{
  imports = [
    ./hyprland
    ./programs
    ./system
    inputs.ff.homeModules.ff
  ];
  programs.home-manager.enable = true;
}
