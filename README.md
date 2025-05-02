# MegaFlake - NixOS System Configuration

![nix-lock-update-status](https://img.shields.io/github/actions/workflow/status/Neochaotics/nixosconf/nix-lock-update.yml?logo=nixos&logoColor=white&label=Lock%20Update&labelColor=%23779ECB)
![nix-flake-check-status](https://img.shields.io/github/actions/workflow/status/Neochaotics/nixosconf/nix-flake-check.yml?logo=nixos&logoColor=white&label=Flake%20Check&labelColor=%23779ECB)
![NixOS Version](https://img.shields.io/badge/NixOS-unstable-blue?logo=nixos&logoColor=white)
![License](https://img.shields.io/github/license/Neochaotics/nixosconf?logo=opensourceinitiative&logoColor=white)
![Last Commit](https://img.shields.io/github/last-commit/Neochaotics/nixosconf?logo=git&logoColor=white)
![Repo Size](https://img.shields.io/github/repo-size/Neochaotics/nixosconf?logo=github&logoColor=white)

## Overview

Comprehensive NixOS system configuration built as a modular flake. Designed to provide reproducible, declarative system configurations with ephemeral root file systems and persistent user data.

## Key Features

- **Impermanence**: Ephemeral root filesystem with persistent user data
- **Home Manager**: Declarative user environment management
- **Agenix**: Secure secret management with GPG and SSH key support
- **Chaotic-Nyx**: Access to additional software packages
- **Multi-Host Support**: Automated host configuration discovery and application
- **Modular Architecture**: Shared configuration through external flakes

## Binary Cache Configuration

Pre-configured binary caches to speed up system builds:

```nix
extra-substituters = [
  "https://cache.nixos.org"
  "https://chaotic-nyx.cachix.org"
  "https://hyprland.cachix.org"
  "https://nix-community.cachix.org"
];
```

## Directory Structure

- **flake.nix**: Core configuration and input definitions
- **hosts/**: Host-specific configurations
- **home/**: Home-manager configurations
- **secrets/**: Encrypted secrets managed by agenix
- **scripts/**: Utility scripts for system management

## Module Integration

### FreedpomFlake Integration

MegaFlake integrates with [FreedpomFlake](https://github.com/freedpom/FreedpomFlake) for shared modules and configurations:

```nix
ff = {
  url = "github:freedpom/FreedpomFlake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

### NixModule Integration

[NixModule](https://github.com/Neochaotics/NixModule) provides additional custom functionality:

```nix
qm = {
  url = "github:Neochaotics/NixModule";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

### Other Module Integrations

- **Stylix**: System-wide theming
- **Disko**: Declarative disk partitioning
- **flake-parts**: Modular flake structure
