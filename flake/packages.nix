_: {
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      packages.bench = pkgs.callPackage ../pkgs/bench/package.nix { };

      apps.bench = {
        type = "app";
        program = "${config.packages.bench}/bin/bench";
      };
    };
}
