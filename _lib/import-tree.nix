{ lib, ... }:
let
  listFilesRecursiveCond =
    dir: condition:
    let
      internalFunc =
        folder:
        let
          contents = builtins.readDir folder;
        in
        lib.concatMap (
          filename:
          let
            subpath = folder + "/${filename}";
            type = contents.${filename};
          in
          if type == "regular" && condition subpath then
            [ subpath ]
          else if type == "directory" then
            internalFunc subpath
          else
            [ ]
        ) (lib.attrNames contents);
    in
    internalFunc dir;
in
path:
listFilesRecursiveCond path (
  n:
  lib.hasSuffix ".nix" n
  && !(lib.hasInfix "/_" (toString n))
  && !(lib.hasInfix "/lib/" (toString n))
  && baseNameOf n != "flake.nix"
  && baseNameOf n != "default.nix"
)
