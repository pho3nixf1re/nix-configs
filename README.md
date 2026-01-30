# NixOS + macOS + SteamOS Unified Configuration

A single Nix flake–based repository supporting:

- **Full NixOS system configurations**
- **nix-darwin macOS system configurations**
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

### First Time Setup

Before building, set up secrets from 1Password:

```bash
# Run the secrets setup script
./setup-smb-secrets.sh
```

This script:
- Generates encryption keys from your SSH key
- Pulls SMB credentials from 1Password
- Creates local encrypted secrets (not committed to git)
- Can be re-run anytime to refresh secrets

### On NixOS

```bash
sudo nixos-rebuild switch --flake .#pho3nixf1re-nixos
```

### On SteamOS or other distros

```bash
nix run home-manager/master -- switch --flake .#deck@steamdeck
```

### On macOS with nix-darwin

First time setup requires installing nix-darwin:

```bash
# Build and activate the darwin configuration
nix run nix-darwin -- switch --flake .#cvent-macos

# After first activation, use darwin-rebuild for subsequent builds
darwin-rebuild switch --flake .#cvent-macos
```

## Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Design principles & patterns
- **[AGENTS.md](docs/AGENTS.md)** - Instructions for AI/human agents
- **[SECRETS.md](docs/SECRETS.md)** - Secrets management with 1Password & sops-nix

- [Architecture & Design](docs/ARCHITECTURE.md) - Design principles and module patterns
- [Agent Instructions](docs/AGENTS.md) - Guidelines for contributing (human & AI)

## Available Configurations

| Configuration | Type | Target | Profiles |
|--------------|------|--------|----------|
| `pho3nixf1re-nixos` | NixOS | Full desktop system | common-user + dev + desktop-system |
| `cvent-macos` | nix-darwin | macOS work system | cvent |
| `deck@steamdeck` | Home Manager | Steam Deck user config | common-user + dev |

## License

MIT
