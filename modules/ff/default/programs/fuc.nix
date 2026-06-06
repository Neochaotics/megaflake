{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fuc
  ];
}
