# Hyprland config generator.
#
# Ported from home-manager's `lib.generators.toHyprconf` (BSD-3-Clause,
# (c) Home Manager contributors) so that hjem renders byte-identical
# `hypr/*.conf` files.
{ lib }:
let
  inherit (lib)
    all
    any
    attrNames
    concatMapStringsSep
    concatStrings
    concatStringsSep
    filterAttrs
    generators
    hasPrefix
    isAttrs
    isList
    mapAttrsToList
    removeAttrs
    replicate
    ;

  toHyprconf =
    {
      attrs,
      indentLevel ? 0,
      importantPrefixes ? [ "$" ],
    }:
    let
      initialIndent = concatStrings (replicate indentLevel "  ");

      toHyprconf' =
        indent: attrs:
        let
          isImportantField = n: _: any (prev: hasPrefix prev n) importantPrefixes;
          importantFields = filterAttrs isImportantField attrs;
          withoutImportantFields = fields: removeAttrs fields (attrNames importantFields);

          allSections = filterAttrs (_n: v: isAttrs v || isList v) attrs;
          sections = withoutImportantFields allSections;

          mkSection =
            n: attrs:
            if isList attrs then
              let
                separator = if all isAttrs attrs then "\n" else "";
              in
              (concatMapStringsSep separator (a: mkSection n a) attrs)
            else if isAttrs attrs then
              ''
                ${indent}${n} {
                ${toHyprconf' "  ${indent}" attrs}${indent}}
              ''
            else
              toHyprconf' indent { ${n} = attrs; };

          mkFields = generators.toKeyValue {
            listsAsDuplicateKeys = true;
            inherit indent;
          };

          allFields = filterAttrs (_n: v: !(isAttrs v || isList v)) attrs;
          fields = withoutImportantFields allFields;
        in
        mkFields importantFields
        + concatStringsSep "\n" (mapAttrsToList mkSection sections)
        + mkFields fields;
    in
    toHyprconf' initialIndent attrs;

  pluginsToHyprconf =
    plugins: importantPrefixes:
    toHyprconf {
      attrs = {
        plugin = map (
          entry: if lib.types.package.check entry then "${entry}/lib/lib${entry.pname}.so" else entry
        ) plugins;
      };
      inherit importantPrefixes;
    };
in
{
  inherit toHyprconf pluginsToHyprconf;
}
