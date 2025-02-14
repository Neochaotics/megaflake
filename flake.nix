{
  description = "NixOS System Configuration";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    # Core Nix dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    stylix.url = "github:danth/stylix";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ff = {
      url = "git+ssh://git@github/freedpom/FreedpomFlake";
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
      url = "https://raw.githubusercontent.com/ngosang/trackerslist/refs/heads/master/trackers_all.txt";
      type = "file";
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
    inputs@{
      flake-parts,
      nixpkgs,
      ...
    }:
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
      ];

      # Per-system configuration
      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config = { };
          };

          _module.args.upkgs = import inputs.nixpkgs-unstable {
            inherit system;
            config = { };
          };

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

              typos.enable = true;
              typos.excludes = [
                "*.png"
                "*.yaml"
                "modules/nixos/programs/nvf.nix"
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
        nixosModules = {
          test = ./modules/nixos;
        };
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
                  upkgs = inputs.nixpkgs-unstable;
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
