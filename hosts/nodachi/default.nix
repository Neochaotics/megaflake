{
  lib,
  inputs,
  self,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.fluxcast-flake.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.hjem.nixosModules.default
    inputs.preservation.nixosModules.default
    inputs.nix-mineral.nixosModules.nix-mineral
    self.modules.nixos.profile-desktop
    self.modules.nixos.profile-gaming
    self.modules.nixos.paseo
    inputs.freedpom.modules.nixos.ntpd
    inputs.freedpom.modules.nixos.locale
    inputs.freedpom.modules.nixos.ananicy
    inputs.freedpom.modules.nixos.nix-daemon
    inputs.freedpom.modules.nixos.performance
    inputs.freedpom.modules.nixos.steam
    ./apps.nix
    ./secrets.nix
    ./services.nix
    ./user.nix
    ./disk-primary.nix
    ./disk-secondary.nix
    ./hardware.nix
    ./gpu.nix
  ];

  networking.nameservers = [ "10.0.1.1" ];

  nixpkgs.flake.source = lib.mkForce null;
}
