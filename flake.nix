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
    # -- Core dependencies --
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # -- System management --
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    preservation.url = "github:nix-community/preservation";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";

    # -- Security and secrets management --
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # -- Development tools --
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    fpFmt = {
      url = "github:freedpom/FreedpomFormatter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # -- Applications and add-ons --
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    trackers = {
      url = "github:ngosang/trackerslist";
      flake = false;
    };

    # -- Custom modules and flakes --
    ff = {
      #url = "path:/home/quinno/github/freedpom/FreedpomFlake";
      #url = "git+https://github.com/freedpom/FreedpomFlake?ref=feat/update-consoles";
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
      #url = "path:/home/quinno/github/Neochaotics/NixModule";
      url = "github:Neochaotics/NixModule";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        ff.follows = "ff";
      };
    };

    # -- Disabled modules (kept for reference) --
    #lix-module = {
    #  url = "git+https://git.lix.systems/lix-project/nixos-module?ref=stable";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };
  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # Supported system types
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Flake modules to import
      imports = [
        inputs.flake-root.flakeModule
        inputs.agenix-rekey.flakeModule
        inputs.fpFmt.flakeModule
      ];

      # NixOS system configurations
      flake.nixosConfigurations = let
        # Import nixpkgs library
        inherit (self.inputs.nixpkgs) lib;

        # Automatically discover all host configurations from the hosts directory
        hostNames = builtins.attrNames (
          lib.attrsets.filterAttrs (_name: type: type == "directory") (builtins.readDir ./hosts)
        );

        # Function to create a NixOS system configuration for each host
        mkHost = hostname:
          self.inputs.nixpkgs.lib.nixosSystem {
            # Special arguments passed to all modules
            specialArgs = {
              inherit
                inputs
                hostname
                lib
                self
                ;
            };

            # Modules to include in each system configuration
            modules = [
              # Host-specific configuration
              ./hosts/${hostname}

              # Core system modules
              inputs.impermanence.nixosModules.impermanence
              inputs.preservation.nixosModules.preservation
              inputs.home-manager.nixosModules.home-manager

              # Security modules
              inputs.agenix.nixosModules.default
              inputs.agenix-rekey.nixosModules.default

              # Package repositories
              inputs.chaotic.nixosModules.default

              # Disabled modules
              #inputs.lix-module.nixosModules.default
            ];
          };
      in
        # Generate configurations for all hosts
        lib.genAttrs hostNames mkHost;

      # Nix-on-Droid configurations
      flake.nixOnDroidConfigurations.tanto = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = {
          inherit inputs self;
          inherit (inputs.nixpkgs) lib;
          hostname = "tanto";
        };
        modules = [
          ./hosts/tanto.nix
        ];
      };
    };
}
