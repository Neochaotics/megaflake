{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [
          config.agenix-rekey.package
          pkgs.age-plugin-yubikey
          pkgs.nix-update
          pkgs.rage
        ];
      };
    };
}
