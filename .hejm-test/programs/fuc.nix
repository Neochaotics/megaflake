{ pkgs, ... }:
{
  flake.modules.nixos.fuc = {
    environment.systemPackages = [ pkgs.fuc ];
  };
}
