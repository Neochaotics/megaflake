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
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";

    # -- Security and secrets management --
    #agenix = {
    #  url = "github:ryantm/agenix";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.darwin.follows = "";
    #};
    #agenix-rekey = {
    #  url = "github:oddlama/agenix-rekey";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    # -- Development tools --
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    fpFmt = {
      url = "github:freedpom/FreedpomFormatter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # -- Applications and add-ons --
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons&rev=8ca0845762f7a664b1d5a920ef3bd03df50311d0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    trackers = {
      url = "github:ngosang/trackerslist";
      flake = false;
    };
    caldera = {
      # -- Custom modules and flakes --
      url = "/home/quinno/github/Caldera";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      ];

      # Flake modules to import
      imports = [
        inputs.flake-root.flakeModule
        #inputs.agenix-rekey.flakeModule
        inputs.fpFmt.flakeModule
        inputs.flake-parts.flakeModules.easyOverlay
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
              {
                nixpkgs.config.allowUnfree = true;
                nixpkgs.hostPlatform = "x86_64-linux";
                networking.hostName = hostname;
                system.stateVersion = "24.11";
              }

              # Host-specific configuration
              ./hosts/${hostname}

              # Core system modules
              inputs.preservation.nixosModules.preservation
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                };
              }

              # Package repositories
              inputs.chaotic.nixosModules.default

              inputs.ff.nixosModules.freedpomFlake
              inputs.qm.nixosModules.qModule
              inputs.disko.nixosModules.disko
            ];
          };
      in
        # Generate configurations for all hosts
        lib.genAttrs hostNames mkHost;
    };
}
