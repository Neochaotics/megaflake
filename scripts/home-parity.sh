#!/usr/bin/env bash
# Home Manager <-> hjem parity harness.
#
#   home-parity.sh baseline   # snapshot the Home Manager generation (needs HM)
#   home-parity.sh check      # diff the current hjem generation against it
#   home-parity.sh show       # print the current hjem generation
#
# Each generation is reduced to "$HOME-relative target -> NAR hash of the linked
# store path", plus the list of packages it installs. Hashing the linked store
# path (rather than what HM/hjem physically place in $HOME) keeps
# symlink-vs-copy differences from producing false positives.
set -euo pipefail

flake_ref="${FLAKE:-git+file:///etc/nixos}"
host="${HOST:-nodachi}"
user="${USER_NAME:-quinno}"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/home-parity"
mode="${1:-}"
home_dir="/home/$user"

mkdir -p "$cache"
work="$cache/${mode:-run}"

gen_prefix="let
  flake = builtins.getFlake \"$flake_ref\";
  lib = flake.inputs.nixpkgs.lib;
"

# Home Manager: home.file keys are $HOME-relative (or absolute), xdg.* keys are
# relative to their XDG root. Entries with enable = false are never activated.
hm_expr="${gen_prefix}
  c = flake.nixosConfigurations.$host.config.home-manager.users.$user;
  src = v: if (v.enable or true) && v ? source && v.source != null then toString v.source else null;
  keep = attrs: builtins.filter (n: (src attrs.\${n}) != null) (builtins.attrNames attrs);
  files = builtins.listToAttrs (map (n: { name = n; value = src c.home.file.\${n}; }) (keep c.home.file))
    // builtins.listToAttrs (map (n: { name = \"\${c.xdg.configHome}/\${n}\"; value = src c.xdg.configFile.\${n}; }) (keep c.xdg.configFile))
    // builtins.listToAttrs (map (n: { name = \"\${c.xdg.dataHome}/\${n}\"; value = src c.xdg.dataFile.\${n}; }) (keep c.xdg.dataFile));
in {
  tsv = lib.concatStringsSep \"\n\" (map (n: n + \"\t\" + files.\${n}) (lib.sort builtins.lessThan (lib.attrNames files)));
  packages = lib.sort builtins.lessThan (map (p: p.pname or (p.name or \"\")) c.home.packages);
}"

# hjem: fileTypeRelativeTo exposes the resolved store path as `source`; target
# is relative to the per-user root / XDG directory.
hjem_expr="${gen_prefix}
  cfg = flake.nixosConfigurations.$host.config;
  u = cfg.hjem.users.$user;
  src = v: if (v.enable or true) && v ? source && v.source != null then toString v.source else null;
  collect = root: attrs:
    builtins.listToAttrs (map (n: let
      v = attrs.\${n};
    in {
      name = \"\${root}/\${v.target or n}\";
      value = src v;
    })
      (builtins.filter (n: (src attrs.\${n}) != null) (builtins.attrNames attrs)));
  files = collect u.directory u.files
    // collect u.xdg.cache.directory u.xdg.cache.files
    // collect u.xdg.config.directory u.xdg.config.files
    // collect u.xdg.data.directory u.xdg.data.files
    // collect u.xdg.state.directory u.xdg.state.files;
in {
  tsv = lib.concatStringsSep \"\n\" (map (n: n + \"\t\" + files.\${n}) (lib.sort builtins.lessThan (lib.attrNames files)));
  packages = lib.sort builtins.lessThan (map (p: p.pname or (p.name or \"\")) u.packages);
}"

hash_tsv() {
  # stdin: target<TAB>source ; stdout: $HOME-relative target<TAB>NAR hash<TAB>source
  #
  # Directory sources are expanded into their files: home-manager linked them
  # recursively while hjem links the directory itself, so comparing the files is
  # what the user actually ends up with in $HOME.
  while IFS=$'\t' read -r target source; do
    [ -n "$source" ] || continue
    rel="${target#"$home_dir"/}"
    if [ ! -e "$source" ]; then
      nix build --no-link "$source" >/dev/null 2>&1 ||
        {
          echo "!! unbuildable: $rel -> $source" >&2
          continue
        }
    fi
    real="$(realpath "$source")"
    if [ -d "$real" ]; then
      while IFS= read -r f; do
        printf '%s\t%s\t%s\n' "${rel}/${f#"$real"/}" "$(nix hash path "$f" | cut -d' ' -f1)" "$f"
      done < <(find "$real" -type f | sort)
    else
      printf '%s\t%s\t%s\n' "$rel" "$(nix hash path "$real" | cut -d' ' -f1)" "$real"
    fi
  done | sort -u
}

capture() {
  # $1 = expression; writes $work.tsv and $work.pkgs
  nix eval --impure --raw --expr "$1" --apply 'x: x.tsv' |
    grep -v '^$' | hash_tsv >"$work.tsv"
  nix eval --impure --raw --expr "$1" --apply 'x: builtins.concatStringsSep "\n" x.packages' |
    grep -v '^$' | sort -u >"$work.pkgs"
}

# hjem's manifest is the authoritative record of what it links, and building it
# realises every file source it references.
capture_hjem() {
  local manifest
  unit_expr="let
    c = (builtins.getFlake \"$flake_ref\").nixosConfigurations.$host.config;
    pkgs = (builtins.getFlake "$flake_ref").inputs.nixpkgs.legacyPackages.x86_64-linux;
  in
  # The activation script string carries the manifest path in its Nix context,
  # so writing it out as a derivation realises the manifest, which in turn
  # realises every file source it links.
  pkgs.writeText \"hjem-activate_-start\" c.systemd.services.\"hjem-activate@\".script"

  nix build --impure --no-link --expr "$unit_expr" >/dev/null
  manifest="$(nix eval --impure --raw --expr \
    "(builtins.getFlake \"$flake_ref\").nixosConfigurations.$host.config.systemd.services.\"hjem-activate@\".script" |
    grep -o '/nix/store/[a-z0-9]*-hjem-manifests' | head -1)"
  paste \
    <(grep -o '"target":"[^"]*"' "$manifest/manifest-$user.json" | sed 's/"target":"//; s/"$//') \
    <(grep -o '"source":"[^"]*"' "$manifest/manifest-$user.json" | sed 's/"source":"//; s/"$//') |
    grep -v '"target":""' | hash_tsv >"$work.tsv"
  nix eval --impure --raw --expr "$hjem_expr" \
    --apply 'x: builtins.concatStringsSep "\n" x.packages' |
    grep -v '^$' | sort -u >"$work.pkgs"
}

case "$mode" in
baseline)
  # putter.json is Home Manager's authoritative manifest of what its
  # activation links, so read the file set from there rather than
  # re-deriving it from Home Manager's option algebra.
  # HM_PKG lets the baseline be re-derived from an already-built home-manager
  # generation after the configuration has moved to hjem.
  hm_pkg="${HM_PKG:-$(nix build --impure --no-link --print-out-paths \
    --expr "(builtins.getFlake \"$flake_ref\").nixosConfigurations.$host.config.home-manager.users.$user.home.activationPackage")}"
  # Every putter.json entry carries exactly one "source" and one "target", and no
  # nested object does, so two greps in document order line up with paste.
  paste \
    <(grep -o '"target":"[^"]*"' "$hm_pkg/putter.json" | sed 's/"target":"//; s/"$//') \
    <(grep -o '"source":"[^"]*"' "$hm_pkg/putter.json" | sed 's/"source":"//; s/"$//') |
    hash_tsv >"$cache/hm-baseline.tsv"
  nix eval --impure --raw --expr "$hm_expr" \
    --apply 'x: builtins.concatStringsSep "\n" x.packages' |
    grep -v '^$' | sort -u >"$cache/hm-baseline.pkgs"
  echo "baseline: $(wc -l <"$cache/hm-baseline.tsv") files, $(wc -l <"$cache/hm-baseline.pkgs") packages -> $cache"
  ;;
show)
  capture_hjem
  cat "$work.tsv"
  ;;
check)
  capture_hjem
  [ -f "$cache/hm-baseline.tsv" ] || {
    echo "no baseline: run '$0 baseline' first" >&2
    exit 66
  }
  nix eval --impure --raw --expr "
      let
        lib = (builtins.getFlake \"$flake_ref\").inputs.nixpkgs.lib;
        set = f:
          lib.listToAttrs (map (l: {
            name = lib.head (lib.splitString \"\t\" l);
            value = lib.elemAt (lib.splitString \"\t\" l) 1;
          }) (lib.filter (l: l != \"\") (lib.splitString \"\n\" (builtins.readFile f))));
        base = set \"$cache/hm-baseline.tsv\";
        now = set \"$work.tsv\";
        missing = lib.filter (n: !(builtins.hasAttr n now)) (lib.attrNames base);
        extra = lib.filter (n: !(builtins.hasAttr n base)) (lib.attrNames now);
        changed = lib.filter (n: (builtins.hasAttr n now) && base.\${n} != now.\${n}) (lib.attrNames base);
        same = lib.length (lib.filter (n: (builtins.hasAttr n now) && base.\${n} == now.\${n}) (lib.attrNames base));
        section = title: xs:
          if xs == [] then \"\"
          else \"\n\" + title + \" (\" + toString (lib.length xs) + \"):\"
            + lib.concatMapStringsSep \"\n\" (n: \"  \" + n) xs;
      in
      (if missing == [] && extra == [] && changed == []
       then \"files: PARITY OK - \" + toString same + \" identical\"
       else \"files: PARITY FAIL\"
         + section \"missing (HM has it, hjem does not)\" missing
         + section \"extra (hjem adds it)\" extra
         + section \"changed (content differs)\" changed)
    "
  diff -u "$cache/hm-baseline.pkgs" "$work.pkgs" >/dev/null &&
    echo "packages: PARITY OK" ||
    {
      echo "packages: PARITY FAIL"
      diff -u "$cache/hm-baseline.pkgs" "$work.pkgs" || true
    }
  ;;
*)
  echo "usage: $0 {baseline|check|show}" >&2
  exit 64
  ;;
esac
