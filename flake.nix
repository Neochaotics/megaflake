{
  description = "Collection of NixOS and Home-Manager presets";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      imports = [
        inputs.home-manager.flakeModules.home-manager
      ];
      flake = {
        nixosModules = {
          qModule = ./nixos;
        };
        homeManagerModules = {
          qModule = ./home-manager;
        };
      };
    };
}
