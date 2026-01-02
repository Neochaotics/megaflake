{ inputs, ... }:
{
  imports = [
    ./hyprland
    ./programs
    ./system
    inputs.ff.homeModules.freedpomFlake
  ];
  programs.home-manager.enable = true;
}
