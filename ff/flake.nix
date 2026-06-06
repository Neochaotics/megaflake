{
  description = "NixOS and Home-Manager presets";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    wm-hypr.url = "github:hyprwm/Hyprland?ref=v0.53.1";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      let
        fmtModule = flake-parts.lib.importApply ./modules/_formatModule.nix { inherit inputs; };
      in
      {
        systems = [
          "aarch64-linux"
          "x86_64-linux"
        ];

        imports = [
          fmtModule
          inputs.home-manager.flakeModules.home-manager
          inputs.flake-parts.flakeModules.easyOverlay
          inputs.flake-parts.flakeModules.partitions
          inputs.flake-parts.flakeModules.modules
          ./modules
        ];
        flake = {
          inherit fmtModule;
        };
      }
    );
}
