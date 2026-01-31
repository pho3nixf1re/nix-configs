# Architecture & Design Principles

This document describes the architectural decisions and design patterns used in this Nix configuration repository.

## Core Philosophy

### One Repository, Multiple Targets

This repository serves two distinct use cases from a single codebase:

- **NixOS hosts** via `nixosConfigurations` - Full system management
- **Non-NixOS systems** via `homeConfigurations` - User-level config only (SteamOS, Arch, Ubuntu, etc.)

### Portable Logic Lives in Home Manager

All user-facing configuration belongs in Home Manager modules:

- Shell configuration (zsh, bash)
- Editor setup (neovim, vscode)
- Development tooling
- Dotfiles and user preferences

Home Manager modules make **no assumptions** about:
- System package managers
- Immutable filesystem layouts
- Init systems or services

### NixOS Modules Are Optional Consumers

The dependency flows one way:

```
NixOS Host → imports → Home Manager modules
```

Never the reverse. This ensures Home Manager configs remain portable.

### Profiles Over Hosts

**Profiles** represent intent:
- `personal.nix` - Baseline tools every user needs
- `dev.nix` - Development-focused additions

**Hosts** represent machines:
- `desktop.nix` - Specific NixOS machine
- `deck-home.nix` - Steam Deck overrides

Hosts should contain minimal configuration—just identity (hostname) and profile imports.

## Module Hierarchy

```
profiles/           ← Compose modules into use-case bundles
    ↑
modules/home/       ← Portable, user-scoped building blocks
modules/nixos/      ← System-scoped building blocks (NixOS only)
    ↑
hosts/              ← Machine-specific identity + profile selection
```

## Flake Structure

### Inputs

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

All inputs follow `nixpkgs` to ensure consistent package versions.

### Outputs

Two output types:

1. **`nixosConfigurations`** - Full system configs for NixOS machines
2. **`homeConfigurations`** - Standalone Home Manager configs for any Linux

## Adding New Configurations

### New NixOS Host

1. Create `hosts/nixos/<hostname>.nix` with hostname and stateVersion
2. Add entry to `flake.nix` under `nixosConfigurations`
3. Import desired profiles

### New Home Manager Target

1. Create `hosts/<distro>/<name>.nix` for distro-specific overrides
2. Add entry to `flake.nix` under `homeConfigurations`
3. Import desired profiles

### New Module

1. Create in `modules/home/` (portable) or `modules/nixos/` (system)
2. Keep focused—one concern per module
3. Import from profiles, not directly from hosts
