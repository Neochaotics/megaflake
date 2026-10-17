# systemd user-unit renderer.
#
# Ported from home-manager's `modules/systemd.nix` (BSD-3-Clause, (c) Home
# Manager contributors) so generated `.service`/`.target` files are
# byte-identical.
{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatLists
    filterAttrs
    isBool
    mapAttrs
    toString
    ;

  # From nixpkgs nixos/modules/system/boot/systemd-lib.nix
  mkPathSafeName = lib.replaceStrings [ "@" ":" "\\" "[" "]" ] [ "-" "-" "-" "" "" ];

  toSystemdIni = lib.generators.toINI {
    listsAsDuplicateKeys = true;
    mkKeyValue =
      key: value:
      let
        value' = if isBool value then (if value then "true" else "false") else toString value;
      in
      "${key}=${value'}";
  };

  # Renders one unit from a Home-Manager-shaped service definition, returning a
  # list of { name, source } entries: the unit itself plus one symlink per
  # [Install] Wants/RequiredBy entry.
  buildUnit =
    style: name: serviceCfg:
    let
      filename = "${name}.${style}";
      pathSafeName = mkPathSafeName filename;

      finalUnit =
        let
          shouldKeepField =
            _section: _key: value:
            value != null && value != [ ];
          shouldKeepSection = _: value: value != { };
          filteredFields = mapAttrs (section: filterAttrs (shouldKeepField section)) serviceCfg;
          filteredSections = filterAttrs shouldKeepSection filteredFields;
        in
        filteredSections;

      # systemd derives unit names from the ultimate link target, hence the
      # `destination`.
      source =
        pkgs.writeTextFile {
          name = pathSafeName;
          text = toSystemdIni finalUnit;
          destination = "/${filename}";
        }
        + "/${filename}";

      install = variant: target: {
        name = "systemd/user/${target}.${variant}/${filename}";
        value = { inherit source; };
      };
    in
    lib.singleton {
      name = "systemd/user/${filename}";
      value = { inherit source; };
    }
    ++ map (install "wants") (serviceCfg.Install.WantedBy or [ ])
    ++ map (install "requires") (serviceCfg.Install.RequiredBy or [ ]);

  buildUnits = style: serviceCfgs: concatLists (lib.mapAttrsToList (buildUnit style) serviceCfgs);
in
{
  inherit buildUnit buildUnits;
}
