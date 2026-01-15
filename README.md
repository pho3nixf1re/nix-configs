# NixOS + SteamOS Unified Configuration

A single Nix flake–based repository supporting:

- **Full NixOS system configurations**
- **Portable Home Manager configurations** for SteamOS (Arch + KDE Plasma) and other non-NixOS distros

## Repository Structure

```
.
├── flake.nix              # Main flake entry point
├── hosts/
│   ├── nixos/
│   │   └── desktop.nix    # NixOS desktop host config
│   └── steamos/
│       └── deck-home.nix  # Steam Deck Home Manager config
├── modules/
│   ├── home/
│   │   ├── base.nix       # Core user tools (git, zsh, etc.)
│   │   ├── dev.nix        # Development packages
│   │   ├── gaming-tools.nix # Shared gaming utilities
│   │   └── steam.nix      # Steam client (desktop only)
│   └── nixos/
│       └── base.nix       # Core NixOS system config
├── profiles/
│   ├── common-user.nix    # Standard user profile
│   ├── dev.nix            # Developer-focused profile
│   └── desktop-system.nix # Desktop system profile
└── docs/
    ├── ARCHITECTURE.md    # Design principles & patterns
    └── AGENTS.md          # Instructions for AI/human agents
```

## Quick Start

### On NixOS

```bash
sudo nixos-rebuild switch --flake .#desktop
```

### On SteamOS or other distros

```bash
nix run home-manager/master -- switch --flake .#deck@steamdeck
```

## Documentation

- [Architecture & Design](docs/ARCHITECTURE.md) - Design principles and module patterns
- [Agent Instructions](docs/AGENTS.md) - Guidelines for contributing (human & AI)

## Available Configurations

| Configuration | Type | Target | Profiles |
|--------------|------|--------|----------|
| `desktop` | NixOS | Full desktop system | common-user + dev + desktop-system |
| `deck@steamdeck` | Home Manager | Steam Deck user config | common-user + dev |

## License

MIT
