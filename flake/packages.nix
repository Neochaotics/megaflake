{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      # Each directory under `pkgs/` is a package with a `package.nix`.
      discovered = lib.filesystem.packagesFromDirectoryRecursive {
        inherit (pkgs) callPackage;
        directory = ../pkgs;
      };
    in
    {
      packages = discovered;

      apps = lib.mapAttrs (name: package: {
        type = "app";
        program = lib.getExe' package (package.meta.mainProgram or package.pname or name);
        meta.description = package.meta.description or "Run ${name}";
      }) discovered;
    };
}
