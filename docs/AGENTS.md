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

Place system-level config in `modules/nixos/`.

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

### Home Manager Modules (`modules/home/`)

#### `modules/home/base.nix` — Universal CLI Essentials

**Purpose**: Tools needed on ALL systems, regardless of use case.

**Include**:
- Shell configuration (zsh, bash)
- Core CLI tools (git, ripgrep, jq, curl, wget)
- Terminal utilities used daily by everyone

**Do NOT include**:
- IDEs or editors (VS Code, Neovim) → use `dev.nix`
- Programming languages or runtimes → use `dev.nix`
- Development tooling (formatters, LSPs, direnv) → use `dev.nix`

```nix
{ pkgs, ... }:

{
  programs.git.enable = true;
  programs.zsh.enable = true;

  home.packages = with pkgs; [
    ripgrep
    jq
  ];
}
```

#### `modules/home/dev.nix` — Development Tools

**Purpose**: Tools for software development workflows.

**Include**:
- IDEs and code editors (VS Code, Neovim, Helix)
- Programming languages and runtimes (Node.js, Python, Rust)
- Development utilities (direnv, formatters, linters, LSPs)
- Build tools and package managers

```nix
{ pkgs, ... }:

{
  programs.vscode.enable = true;
  programs.direnv.enable = true;

  home.packages = with pkgs; [
    nodejs
    python3
    nixpkgs-fmt
    nil
  ];
}
```

#### `modules/home/gaming-tools.nix` — Shared Gaming Utilities

**Purpose**: Gaming tools useful on ALL platforms (including SteamOS).

**Include**:
- Game launchers (Lutris, Heroic)
- Compatibility layers (ProtonUp-Qt)
- Game utilities (MangoHud, Goverlay)
- Emulators and game management tools

**Do NOT include**: Steam client (use `steam.nix` for that)

```nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    lutris
    heroic
    protonup-qt
    mangohud
    goverlay
  ];
}
```

#### `modules/home/steam.nix` — Steam Client

**Purpose**: Steam platform client for desktop systems.

**Only for**: Non-SteamOS systems (SteamOS has Steam built-in)

```nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    steam
  ];
}
```

Keep all Home Manager modules portable—no `services.*` or hardware config.

### NixOS Modules (`modules/nixos/`)

```nix
{ config, pkgs, ... }:

{
  # System-level concerns only
  services.openssh.enable = true;

  # User creation (system-level)
  users.users.pho3nixf1re = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
}
```

### Profiles (`profiles/`)

Compose modules into meaningful bundles:

- **`common-user.nix`** — Base user setup (imports `base.nix`, `dev.nix`, `gaming-tools.nix`)
- **`dev.nix`** — Developer profile (imports `modules/home/dev.nix`)
- **`desktop-system.nix`** — Desktop-specific profile (imports `steam.nix`, `gaming-tools.nix`)

```nix
{ pkgs, ... }:

{
  imports = [
    ../modules/home/base.nix
    ../modules/home/dev.nix
  ];

  # Profile-wide settings
  home.username = "pho3nixf1re";
  home.homeDirectory = "/home/pho3nixf1re";
}
```

## Profile Usage Patterns

- **NixOS Desktop (`desktop`)**: Imports `common-user` + `dev` + `desktop-system`
  - Full development environment
  - Steam client (via `desktop-system`)
  - Shared gaming tools (via `common-user`)
  - Desktop environment (KDE Plasma + Wayland)

- **Steam Deck (`deck@steamdeck`)**: Imports `common-user` + `dev`
  - Development tools for on-the-go coding
  - Shared gaming tools (Lutris, Heroic, MangoHud, etc.)
  - NO Steam client (already installed on SteamOS)
  - Uses fixed username `deck`
```

## Adding Features

### Checklist

1. **Identify scope**: Is this user-level or system-level?
2. **Choose location**:
   - User-level → `modules/home/`
   - System-level → `modules/nixos/`
3. **Create focused module**: One concern per file
4. **Update profile**: Import new module where appropriate
5. **Test both paths**: Verify works on NixOS and standalone Home Manager

### Example: Adding Neovim Configuration

```nix
# modules/home/neovim.nix
{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
```

Then import from `profiles/dev.nix`:

```nix
imports = [
  ../modules/home/neovim.nix
  # ... other imports
];
```

## Testing Changes

### NixOS

```bash
# Build without switching
nixos-rebuild build --flake .#desktop

# Switch to new config
sudo nixos-rebuild switch --flake .#desktop
```

### Home Manager Standalone

```bash
# Build without activating
nix build .#homeConfigurations.deck@steamdeck.activationPackage

# Activate
nix run home-manager/master -- switch --flake .#deck@steamdeck
```

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
