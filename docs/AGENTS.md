# Instructions for Coding Agents

This document provides guidelines for AI assistants and human contributors working on this Nix configuration repository.

## Golden Rules

### Do NOT

- ❌ Add system services or kernel config to Home Manager modules
- ❌ Put host-specific logic in profiles or modules
- ❌ Assume SteamOS system files are writable or persistent
- ❌ Create circular dependencies between modules
- ❌ Duplicate configuration across hosts—use profiles instead

### Do

- ✅ Keep modules minimal and single-purpose
- ✅ Prefer profiles for composing functionality
- ✅ Test that Home Manager configs work standalone
- ✅ Document non-obvious configuration choices
- ✅ Keep defaults minimal—users opt-in to features

## Platform Considerations

### NixOS

Full system control is available:
- Systemd services
- Kernel parameters
- Boot configuration
- Network management
- User creation

Place system-level config in `../modules/nixos/`.

### SteamOS (and Immutable Distros)

**Critical constraints:**
- Root filesystem resets on updates
- System packages may be overwritten
- Only `$HOME` is reliably persistent

All SteamOS configuration must live in Home Manager. Never assume:
- Ability to install system packages
- Persistent `/etc` modifications
- Control over system services

### Generic Linux

For other distros (Ubuntu, Fedora, Arch):
- Use `homeConfigurations` output
- Nix handles package installation via user profile
- No assumptions about system Nix installation method

## Module Guidelines

### Home Manager Modules

Place Home Manager modules in `../modules/home/`.

### MacOS Modules

Place MacOS (darwin) modules in `../modules/darwin/`.

### NixOS Modules

Place NixOS system modules in `../modules/system/`.

### Profiles (`profiles/`)

Compose modules into meaningful bundles. Examples:

- **`personal.nix`** — Base user setup used outside of work machines.
- **`dev.nix`** — Developer profile.
- **`desktop-system.nix`** — Desktop-specific profile.

## Adding Features

### Checklist

1. **Identify scope**: Is this user-level or system-level? Is this MacOS or Linux?
2. **Choose location**:
   - User-level -> `../modules/home/`
   - MacOS-specific -> `../modules/darwin/`
   - System-level -> `../modules/system/`
3. **Create focused module**: One concern per file
4. **Update profile**: Import new module where appropriate

## Common Patterns

### Conditional Configuration

```nix
{ config, lib, pkgs, ... }:

{
  # Only enable if another program is enabled
  programs.starship = lib.mkIf config.programs.zsh.enable {
    enable = true;
  };
}
```

### Package Overlays

Add to `flake.nix` if needed:

```nix
pkgs = import nixpkgs {
  inherit system;
  overlays = [ /* your overlays */ ];
};
```

### Extra Arguments to Modules

Pass through `specialArgs` (NixOS) or `extraSpecialArgs` (Home Manager):

```nix
# In flake.nix
nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; };
  # ...
};
```

