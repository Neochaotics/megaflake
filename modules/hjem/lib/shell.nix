# Shell helpers.
#
# Ported from home-manager's `modules/lib/shell.nix` (BSD-3-Clause, (c) Home
# Manager contributors).
{ lib }:
let
  inherit (lib)
    concatStringsSep
    map
    mapAttrsToList
    optional
    ;

  exportVar =
    n: v:
    let
      value = if builtins.isBool v then lib.boolToString v else toString v;
    in
    ''export ${n}="${value}"'';

  # Wrap a list of strings to a given line width, packing as many items as
  # possible per line.
  wrapLines =
    items: maxWidth:
    let
      step =
        acc: item:
        let
          potentialLine = if acc.currentLine == "" then item else "${acc.currentLine} ${item}";
        in
        if lib.stringLength potentialLine <= maxWidth then
          acc // { currentLine = potentialLine; }
        else
          acc
          // {
            finishedLines = acc.finishedLines ++ [ acc.currentLine ];
            currentLine = item;
          };
      foldResult = lib.foldl' step {
        finishedLines = [ ];
        currentLine = "";
      } items;
    in
    foldResult.finishedLines ++ optional (foldResult.currentLine != "") foldResult.currentLine;

  # Formats the contents of a shell array, wrapping at 78 columns.
  formatShellArrayContent =
    items: "\n  ${concatStringsSep "\n  " (wrapLines (map lib.escapeShellArg items) 78)}\n";
in
{
  export = exportVar;
  exportAll =
    vars: concatStringsSep "\n" (mapAttrsToList exportVar (lib.filterAttrs (_k: v: v != null) vars));

  # Search variables are exported as "<values>${VAR:+:}$VAR" so that they
  # extend rather than replace whatever the session already had.
  prependToVar =
    sep: n: v:
    "${concatStringsSep sep v}\${${n}:+${sep}}\$${n}";

  inherit formatShellArrayContent;

  yesNo = value: if value then "yes" else "no";
}
