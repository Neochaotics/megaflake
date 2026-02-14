{ withSystem, inputs, ... }: {
  perSystem = { system, pkgs, ... }: {
    # pkgs is already available here, but let's configure it explicitly if needed
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };

    # Now use this configured pkgs in your packages, devShells, etc.
    devShells.default = pkgs.mkShell {
      nativeBuildInputs = [
        inputs.agenix-rekey.legacyPackages.${system}.agenix-rekey
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
          modules = [
            ./hosts/${hostname}
            inputs.nixpkgs.nixosModules.readOnlyPkgs
            ({ config, ... }: {
              # Use the configured pkgs from perSystem
              nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system (
                { pkgs, ... }: # perSystem module arguments
                pkgs
              );
              
              networking.hostName = hostname;
              system.stateVersion = "24.11";
              
              # Include the stable pkgs in specialArgs
              _module.args.pkgs-stable = import inputs.nixpkgs-stable {
                inherit (config.nixpkgs) hostPlatform;
                config.allowUnfree = true;
              };
            })
          ];
          specialArgs = {
            inherit
              inputs
              hostname
              lib
              ;
          };
        };
    in
    lib.genAttrs hostNames mkHost;
}