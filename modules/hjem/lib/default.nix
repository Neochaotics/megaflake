# Helpers shared by the hjem modules in this tree.
#
# The modules import the pieces they need directly (for example
# `import ../lib/shell.nix { inherit lib; }`) so that they carry no extra
# module arguments. This entry point is kept for ad-hoc use from a REPL.
{ lib }:
{
  inherit (import ./hyprconf.nix { inherit lib; })
    pluginsToHyprconf
    toHyprconf
    ;

  shell = import ./shell.nix { inherit lib; };
  ssh = import ./ssh.nix { inherit lib; };
}
