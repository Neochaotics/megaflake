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
    # Core Nix dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
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

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ff = {
      url = "github:freedpom/FreedpomFlake";
      inputs.nixpkgs.follows = "nixpkgs";
      #inputs.home-manager.follows = "home-manager";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";

    fpFmt = {
      url = "github:freedpom/FreedpomFormatter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    #lix-module = {
    #  url = "git+https://git.lix.systems/lix-project/nixos-module?ref=stable";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qm = {
      url = "github:Neochaotics/NixModule";
      inputs.nixpkgs.follows = "nixpkgs";
      #inputs.home-manager.follows = "home-manager";
    };

    trackers = {
      url = "github:ngosang/trackerslist";
      flake = false;
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        inputs.flake-root.flakeModule
        inputs.agenix-rekey.flakeModule
        inputs.fpFmt.flakeModule
      ];

      # NixOS system configurations
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
                ./hosts/${hostname}
                inputs.impermanence.nixosModules.impermanence
                inputs.home-manager.nixosModules.home-manager
                inputs.agenix.nixosModules.default
                inputs.agenix-rekey.nixosModules.default
                #inputs.lix-module.nixosModules.default
                inputs.chaotic.nixosModules.default
              ];

            };
        in
        lib.genAttrs hostNames mkHost;
    };
}
