{
  description = "NixOS System Configuration";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://chaotic-nyx.cachix.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons&rev=8ca0845762f7a664b1d5a920ef3bd03df50311d0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ff = {
      url = "github:freedpom/FreedpomFlake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.52.1";
    };
  };
  outputs =
    inputs@{
      self,
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
        inputs.ff.fmtModule
        inputs.flake-parts.flakeModules.easyOverlay
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              config.agenix-rekey.package
              pkgs.age-plugin-yubikey
              pkgs.rage
            ];
          };

          packages = {
            antec-flux-pro-display = pkgs.callPackage ./packages/antec-flux-pro-display.nix { };
            antec-flux-pro-display-udev = pkgs.callPackage ./packages/antec-flux-pro-display-udev.nix { };
          };
        };

      flake = {
        nixosModules = {
          qModule = ./modules/nixos;
        };
        homeModules = {
          qModule = ./modules/home-manager;
        };

        nixosConfigurations =
          let
            inherit (self.inputs.nixpkgs) lib;
            hostNames = builtins.attrNames (
              lib.attrsets.filterAttrs (_name: type: type == "directory") (builtins.readDir ./hosts)
            );
            mkHost =
              hostname:
              self.inputs.nixpkgs.lib.nixosSystem {
                specialArgs = {
                  inherit
                    inputs
                    hostname
                    lib
                    self
                    ;
                  pkgs-stable = import self.inputs.nixpkgs-stable {
                    system = "x86_64-linux";
                    config.allowUnfree = true;
                    nixpkgs.hostPlatform = "x86_64-linux";
                  };
                };
                modules = [
                  {
                    nixpkgs.config.allowUnfree = lib.mkForce true;
                    nixpkgs.hostPlatform = "x86_64-linux";
                    networking.hostName = hostname;
                    system.stateVersion = "24.11";
                  }
                  ./hosts/${hostname}
                ];
              };
          in
          lib.genAttrs hostNames mkHost;
      };
    };
}
