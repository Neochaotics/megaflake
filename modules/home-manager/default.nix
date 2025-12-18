{ inputs, ... }:
{
  imports = [
    ./hyprland
    ./niri
    ./programs
    ./system
    inputs.ff.homeModules.freedpomFlake
  ];
  programs.home-manager.enable = true;
}
