{
  # MegaFlake - A comprehensive NixOS system configuration
  description = "NixOS System Configuration";

  # Binary cache configuration for faster builds
  nixConfig = {
    # Binary cache servers (substituters)
    extra-substituters = [
      "https://cache.nixos.org"
      "https://chaotic-nyx.cachix.org"
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    # Public keys for binary cache verification
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
    #agenix = {
    #  url = "github:ryantm/agenix";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.darwin.follows = "";
    #};
    #agenix-rekey = {
    #  url = "github:oddlama/agenix-rekey";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    fpFmt = {
      url = "github:freedpom/FreedpomFormatter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons&rev=8ca0845762f7a664b1d5a920ef3bd03df50311d0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ff = {
      url = "github:freedpom/FreedpomFlake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    qm = {
      url = "github:Neochaotics/NixModule";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        ff.follows = "ff";
      };
    };
  };
  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # Supported system types
      systems = [
        "x86_64-linux"
      ];

      # Flake modules to import
      imports = [
        inputs.flake-root.flakeModule
        #inputs.agenix-rekey.flakeModule
        inputs.fpFmt.flakeModule
        inputs.flake-parts.flakeModules.easyOverlay
      ];

      flake.nixosConfigurations =
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
              };
              modules = [
                {
                  nixpkgs.config.allowUnfree = lib.mkForce true;
                  nixpkgs.hostPlatform = "x86_64-linux";
                  networking.hostName = hostname;
                  system.stateVersion = "24.11";
                }
                ./hosts/${hostname}
                inputs.chaotic.nixosModules.default
                inputs.ff.nixosModules.freedpomFlake
                inputs.qm.nixosModules.qModule
                inputs.disko.nixosModules.disko
              ];
            };
        in
        lib.genAttrs hostNames mkHost;
    };
}
