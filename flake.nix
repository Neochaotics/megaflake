{
  description = "NixOS System Configuration";

  inputs = {
    # Core Nix dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    stylix.url = "github:danth/stylix";
    sops-nix = {
      url = "github:Mic92/sops-nix";
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

    # Development and formatting tools
    treefmt-nix.url = "github:numtide/treefmt-nix";
    devshell.url = "github:numtide/devshell";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";

    # Flake infrastructure
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.devshell.flakeModule
        inputs.flake-root.flakeModule
        inputs.git-hooks-nix.flakeModule
      ];

      # Per-system configuration
      perSystem =
        { config, pkgs, ... }:
        {
          # Code formatting and linting setup
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
              config.treefmt.build.wrapper
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
      flake = {
        nixosConfigurations =
          let
            inherit (nixpkgs) lib;
            hostNames = builtins.attrNames (builtins.readDir ./hosts);
            mkHost =
              hostname:
              nixpkgs.lib.nixosSystem {
                specialArgs = {
                  inherit inputs hostname lib;
                  outputs = inputs.self;
                };
                modules = [
                  ./hosts/${hostname}
                  inputs.impermanence.nixosModules.impermanence
                ];
              };
          in
          lib.genAttrs hostNames mkHost;
      };
    };
}
