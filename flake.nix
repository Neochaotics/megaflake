{
  description = "NixOS System Configuration";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
    nix-mineral.url = "github:cynicsketch/nix-mineral";
    preservation.url = "github:nix-community/preservation";
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem-rum = {
      url = "github:snugnug/hjem-rum";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hjem.follows = "hjem";
    };
    # Opencode comes via freedpom (single consolidated hjem module +
    # pinned opencode v2 package); no separate input here.
    paseo = {
      url = "github:getpaseo/paseo";
    };
    freedpom = {
      url = "path:/home/quinno/Documents/projects/freedpom/flake/";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    fluxcast-flake.url = "github:noblepayne/fluxcast-flake";
  };
  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        inputs.flake-root.flakeModule
        inputs.agenix-rekey.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.flake-parts.flakeModules.modules
        ./nixos.nix
        ./pkgs.nix
      ];

      perSystem =
        { config, ... }:
        {
          treefmt.config = {
            inherit (config.flake-root) projectRootFile;
            programs = {
              nixfmt.enable = true;
              deadnix.enable = true;
            };
          };
        };

      flake.nixosModules.ffDefault = ./modules/ff/nixosModules.nix;
      flake.hjemModules.default = ./modules/hjem;
    };
}
