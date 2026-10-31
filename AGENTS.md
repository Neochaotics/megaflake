# AGENTS.md

> Rules for working in this NixOS flake.

## Verify before claiming done

| Command | What it catches |
| --- | --- |
| `nix fmt` | Formatting |
| `nix flake check` | Evaluation, module conflicts, assertions, packages, devShell |
| `nix build .#nixosConfigurations.nodachi.config.system.build.toplevel` | Image and `runCommand` failures |

Stage new files before evaluating; an untracked file is not part of the flake
source.

## Layout contract

- `flake/` is auto-imported by `flake.nix`; every `.nix` file there is a
  flake-parts module.
- `flake/modules.nix` owns `flake.modules.nixos.*` and `flake.modules.hjem.*`.
- `flake/profiles.nix` composes feature modules into profiles.
- `modules/ff/` holds reusable NixOS feature modules. They are not
  auto-imported; export them from `flake/modules.nix`.
- `modules/hjem/` holds reusable hjem feature modules.
- `hosts/nodachi/` holds host-specific data only.
- `pkgs/<name>/package.nix` is auto-discovered; no manual package registration.

## Rules

- NEVER put feature logic in a host module. Hosts collect imports and data.
- Use `config.constants.username`, `config.constants.home`, and
  `config.constants.stateVersion` rather than hardcoding the user.
- Give every option a `type`, `default`, and `description`.
- Do not modify unrelated uncommitted work. Check `git status` before staging.
- Do not commit, push, or deploy unless explicitly asked.
