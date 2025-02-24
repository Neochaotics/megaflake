{
  description = "NixOS System Configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://chaotic-nyx.cachix.org"
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  inputs = {
    # Core Nix dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ff = {
      url = "github:freedpom/FreedpomFlake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    qm = {
      url = "github:Neochaotics/NixModule";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System and state management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";

    # Application specific inputs
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    trackers = {
      url = "github:ngosang/trackerslist";
      flake = false;
    };

    # Development and formatting tools
    treefmt-nix.url = "github:numtide/treefmt-nix";
    devshell.url = "github:numtide/devshell";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";

    # Flake infrastructure
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";

    hyprland.url = "github:hyprwm/Hyprland";
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
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
        inputs.treefmt-nix.flakeModule
        inputs.devshell.flakeModule
        inputs.flake-root.flakeModule
        inputs.git-hooks-nix.flakeModule
        inputs.agenix-rekey.flakeModule
      ];

      # Per-system configuration
      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          # Code formatting and linting setup
          flake-root.projectRootFile = "flake.nix";
          agenix-rekey.nixosConfigurations = inputs.self.nixosConfigurations;
          treefmt.config = {
            inherit (config.flake-root) projectRootFile;
            flakeCheck = false;
            programs = {
              # Nix formatting tools
              nixfmt = {
                enable = true;
                package = pkgs.nixfmt-rfc-style;
              };
              statix.enable = true; # Static analysis for Nix
              deadnix.enable = true; # Detect dead code in Nix

              typos.enable = true;
              typos.excludes = [
                "*.png"
                "*.yaml"
                "modules/QModule/nixos/programs/nvf.nix"
                "secrets/"
              ];

              # Additional formatters
              actionlint.enable = true; # GitHub Actions linter
              mdformat.enable = true; # Markdown formatter
              yamlfmt.enable = true;
              shfmt.enable = true;
            };
          };

          # Development environment configuration
          devshells.default = {
            name = "nixdev";
            motd = ""; # Message of the day
            packages = [
              pkgs.nil # Nix Language Server
              pkgs.nixd
              config.treefmt.build.wrapper
              config.agenix-rekey.package
            ] ++ (pkgs.lib.attrValues config.treefmt.build.programs);
          };

          # Git pre-commit hooks
          pre-commit.settings.hooks = {
            treefmt = {
              enable = true;
              package = config.treefmt.build.wrapper;
            };
            statix = {
              enable = true;
              package = config.treefmt.build.programs.statix;
            };
          };
        };

      # NixOS system configurations
      flake.nixosConfigurations =
        let
          inherit (self.inputs.nixpkgs) lib;
          hostNames = builtins.attrNames (builtins.readDir ./hosts);
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
                inputs.lix-module.nixosModules.default
              ];
            };
        in
        lib.genAttrs hostNames mkHost;
    };
}
