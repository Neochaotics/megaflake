{
  description = "NixOS System Configuration";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    # System management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.flake-root.flakeModule
      ];
      perSystem =
        { config, pkgs, ... }:
        {
          # Development shell configuration
          devShells.default = import ./shell.nix { inherit pkgs config; };

          treefmt.config = {
            inherit (config.flake-root) projectRootFile;

            programs = {
              nixfmt.enable = true; # Format nix code
              nixfmt.package = pkgs.nixfmt-rfc-style;
              statix.enable = true; # Static analysis of nix code
              deadnix.enable = true; # Scan for dead nix code
              actionlint.enable = true; # Lint github actions
              mdformat.enable = true; # Format markdown (e.g. README.md :) )
            };
          };
        };
        flake = {...}: {
          nixosConfigurations = let
            # Load all hosts from the hosts directory
            hostNames = builtins.attrNames (builtins.readDir ./hosts);

            mkHost = hostname:
              nixpkgs.lib.nixosSystem {
                specialArgs = {
                  inherit inputs hostname;
                  outputs = inputs.self;
                };
                modules = [ ./hosts/${hostname} ];
              };
          in
            nixpkgs.lib.genAttrs hostNames mkHost;
        };
    };
}
