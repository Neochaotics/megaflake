{ withSystem, inputs, ... }:
{
  perSystem =
    {
      config,
      system,
      pkgs,
      ...
    }:
    {
      # Ensure pkgs allows unfree packages
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [
          config.agenix-rekey.package
          pkgs.age-plugin-yubikey
          pkgs.rage
        ];
      };

      packages = {
        antec-flux-pro-display = pkgs.callPackage ./packages/antec-flux-pro-display.nix { };
        antec-flux-pro-display-udev = pkgs.callPackage ./packages/antec-flux-pro-display-udev.nix { };
      };
    };

  flake.nixosConfigurations =
    let
      inherit (inputs.nixpkgs) lib;
      hostNames = builtins.attrNames (
        lib.attrsets.filterAttrs (_name: type: type == "directory") (builtins.readDir ./hosts)
      );
      mkHost =
        hostname:
        inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/${hostname}
            (
              _:
              {
                networking.hostName = hostname;
                system.stateVersion = "24.11";
                nixpkgs.hostPlatform = "x86_64-linux";

                # Use the configured pkgs from perSystem
                nixpkgs.pkgs = withSystem "x86_64-linux" ({ pkgs, ... }: pkgs);

                _module.args.pkgs-stable = import inputs.nixpkgs-stable {
                  system = "x86_64-linux";
                  config.allowUnfree = true;
                };
              }
            )
          ];
          specialArgs = {
            inherit inputs hostname lib;
            inherit (inputs) self;
          };
        };
    in
    lib.genAttrs hostNames mkHost;
}
