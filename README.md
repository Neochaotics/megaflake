# NixOS configuration

A flake-parts NixOS configuration for `nodachi`, built with hjem, agenix, disko,
and selected modules from the local `freedpom` flake.

## Layout

| Path | Purpose |
| --- | --- |
| `flake/` | Flake-parts glue; auto-imported by `flake.nix` |
| `flake/hosts.nix` | Host factory and per-system `pkgs` |
| `flake/modules.nix` | Exports feature modules under `flake.modules.*` |
| `flake/profiles.nix` | Composite profiles such as `profile-desktop` |
| `modules/ff/` | Feature NixOS modules |
| `modules/hjem/` | Reusable hjem modules |
| `hosts/nodachi/` | Host declaration, hardware, disks, user data |
| `pkgs/` | Packages discovered from `pkgs/<name>/package.nix` |

## Commands

```sh
nix fmt
nix flake check
nix build .#nixosConfigurations.nodachi.config.system.build.toplevel
```

The host toplevel build catches image and `runCommand` failures that
`nix flake check` does not build.

## Working rules

- Hosts collect; profiles and feature modules implement.
- Put host-specific data in `hosts/nodachi/`.
- Put reusable NixOS features in `modules/ff/` and export them from
  `flake/modules.nix`.
- Put reusable hjem features in `modules/hjem/`.
- Use `config.constants.username`, `config.constants.home`, and
  `config.constants.stateVersion` instead of hardcoding user data.
