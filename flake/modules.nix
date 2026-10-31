{
  flake.modules = {
    nixos.ffDefault = ../modules/ff/nixosModules.nix;
    hjem.default = ../modules/hjem;
  };

  # Compatibility alias for existing consumers.
  flake.nixosModules.ffDefault = ../modules/ff/nixosModules.nix;
}
