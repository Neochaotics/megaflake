{ withSystem, inputs, ... }:
{
  perSystem =
    {
      config,
      system,
      ...
    }:
    {
      # Ensure pkgs allows unfree packages and exposes local packages.
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [
          (_final: _prev: {
            local = config.packages // {
              # Used by freedpom modules such as steam.
              proton-cachyos-bin = inputs.freedpom.packages.${system}.proton-cachyos-bin;
            };
          })
        ];
      };
    };

  flake.nixosConfigurations =
    let
      inherit (inputs.nixpkgs) lib;
      hostNames = builtins.attrNames (
        lib.attrsets.filterAttrs (_name: type: type == "directory") (builtins.readDir ../hosts)
      );
      mkHost =
        hostname:
        let
          system = inputs.freedpom.flib.facter.facterSystem inputs.self hostname;
        in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ../hosts/${hostname}
            inputs.self.modules.nixos.constants
            (_: {
              networking.hostName = hostname;

              # Use the configured pkgs from perSystem
              nixpkgs.pkgs = withSystem system ({ pkgs, ... }: pkgs);

              _module.args.pkgs-stable = import inputs.nixpkgs-stable {
                inherit system;
                config.allowUnfree = true;
              };
              _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
              };
            })
          ];
          specialArgs = {
            inherit inputs hostname lib;
            inherit (inputs) self;
          };
        };
    in
    lib.genAttrs hostNames mkHost;
}
