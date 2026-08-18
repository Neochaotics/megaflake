{ pkgs, ... }:
{
  flake.modules.nixos.uutils = {
    environment.systemPackages = [ pkgs.uutils-coreutils ];
  };
}
