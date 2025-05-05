{
  description = "Collection of NixOS and Home-Manager presets";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fpFmt = {
      url = "github:freedpom/FreedpomFormatter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    obsidian-nvim.url = "github:epwalsh/obsidian.nvim";

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.obsidian-nvim.follows = "obsidian-nvim";
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
        inputs.fpFmt.flakeModule
      ];
      flake = {
        nixosModules = {
          qModule = ./nixos;
        };
        homeModules = {
          qModule = ./home-manager;
        };
      };
    };
}
