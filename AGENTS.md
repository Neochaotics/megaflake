# AGENTS.md - NixOS Configuration Guide

This file provides guidelines for agents working with this NixOS flake-based system configuration.

## Build/Lint/Test Commands

### Standard Nix Commands

```bash
nix fmt                    # Format all Nix files (FreedpomFlake)
nix flake check            # Validate flake structure and outputs
nix flake show             # Display all flake outputs
```

### NH Commands

```bash
nh os build . -H <hostname>  # Build NixOS config
nh clean                     # Enhanced garbage collection
nh search                    # Fast package search via Elasticsearch
```

## Code Style Guidelines

### Formatting

- Use 2-space indentation for Nix code
- Maximum line length: 100 characters (soft limit)
- Use `lib.mkForce` to override module defaults
- Use `lib.mkDefault` to set low-priority defaults (priority 1000)

### Imports

- Organize imports logically: NixOS modules, Home Manager modules, then input modules
- Example host imports:
  ```nix
  imports = [
    inputs.agenix.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    self.nixosModules.qModule
    ./hardware.nix
  ];
  ```

### Module Structure

- Module function arguments vary based on needs:
  ```nix
  { lib, config, pkgs, inputs, self, pkgs-stable, ... }:
  let
    cfg = config.qm.xxx;
  in
  {
    imports = [ ... ];
    options.qm.xxx = { ... };
    config = lib.mkIf cfg.enable { ... };
  }
  ```

### Option Naming

- All custom options use `qm.` prefix (e.g., `qm.desktop.hypr.land`, `qm.wireguard`)
- Use `lib.mkEnableOption` for enable options

### Key Patterns

```nix
# Option declaration
options.qm.foo = {
  enable = lib.mkEnableOption "Enable foo";
  bar = lib.mkOption {
    type = lib.types.str;
    default = "defaultvalue";
  };
};

# Config with conditionals
config = lib.mkIf cfg.enable {
  services.foo.enable = true;
};
```

## Nix Module System Reference

### Common Types

| Type | Description | Merging Behavior |
|------|-------------|------------------|
| `lib.types.lines` | Strings | Concatenated with newlines |
| `lib.types.str` | String | Error on multiple definitions |
| `lib.types.bool` | Boolean | Last definition wins |
| `lib.types.int` | Integer | Error on multiple definitions |
| `lib.types.package` | Nix package | Last definition wins |
| `lib.types.listOf t` | List of type t | Concatenated |
| `lib.types.attrsOf t` | Attribute set of type t | Merged |
| `lib.types.submodule` | Nested module | Merged recursively |
| `lib.types.nullOr t` | Type t or null | Last definition wins |
| `lib.types.enum [a b c]` | One of listed values | Error on multiple definitions |
| `lib.types.either t1 t2` | Type t1 or t2 | Type-checked |
| `lib.types.ints.between lo hi` | Integer in range | Error on multiple definitions |
| `lib.types.strMatching "regex"` | String matching regex | Error on multiple definitions |

### Key Functions

- `lib.mkOption` - Declare an option
- `lib.mkEnableOption` - Convenience for boolean options
- `lib.mkIf condition expr` - Conditional config (no value if false)
- `lib.mkDefault expr` - Set low-priority default (priority 1000)
- `lib.mkForce expr` - Override with highest priority
- `lib.concatStringsSep sep list` - Join list elements with separator
- `lib.escapeShellArg str` - Escape string for shell
- `lib.optional condition val` - Include value conditionally
- `lib.boolToString bool` - Convert bool to string
- `lib.filter pred list` - Filter list by predicate
- `lib.attrValues attrs` - Get values from attribute set

### Module Evaluation

- The `config` argument contains evaluated option values from all modules
- Option values cannot be accessed in the same module that defines them (use `config` argument)
- Use `lib.genAttrs` to generate multiple similar configurations

## Project Structure

```
/etc/nixos/
├── flake.nix              # Flake definition and inputs
├── nixos.nix              # Flake-parts module, host generation
├── .github/workflows/     # CI (flake check, nix fmt)
├── hosts/
│   ├── nodachi/           # Host-specific NixOS config
│   ├── wakizashi/
│   └── kozuka/
├── modules/
│   ├── nixos/             # NixOS module definitions
│   │   ├── default.nix
│   │   ├── stylix.nix
│   │   ├── wireguard.nix
│   │   └── programs/
│   └── home-manager/     # Home Manager module definitions
│       ├── default.nix
│       ├── hyprland/
│       └── programs/
└── packages/              # Custom packages
```

### Adding a New Host

1. Create directory `hosts/<hostname>/`
1. Add NixOS configuration files (default.nix, hardware.nix, disks.nix, home.nix)
1. Add Home Manager configuration in `hosts/<hostname>/home.nix`
1. The host is automatically detected and built via `nixos.nix`

### Adding a New Module

1. Create module file in appropriate location (`modules/nixos/` or `modules/home-manager/`)
1. Define options using `lib.mkOption` and `lib.mkEnableOption`
1. Import module in parent `default.nix`
1. Use `qm.` prefix for option names

## Security Notes

- Never commit secrets or keys to the repository
- Use agenix for secret management
- Secrets stored in `secrets/` directory
