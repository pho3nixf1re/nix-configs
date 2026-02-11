# NixOS + macOS + SteamOS Unified Configuration

A single Nix flake–based repository supporting:

- **Full NixOS system configurations**
- **nix-darwin macOS system configurations**
- **Portable Home Manager configurations** for SteamOS (Arch + KDE Plasma) and other non-NixOS distros

## Repository Structure

```
.
├── flake.nix              # Main flake entry point
├── hosts/                 # Host-specific configurations (NixOS, nix-darwin, Home Manager)
├── modules/               # Reusable Nix modules organized by system type
│   ├── home/             # Home Manager user configurations and dotfiles
│   ├── darwin/           # macOS (nix-darwin) specific modules
│   ├── system/           # System-level configurations
│   └── shells/           # Shell environment and development shells
├── profiles/             # Composable profiles that combine multiple modules
├── secrets/              # Encrypted secrets (managed via sops-nix)
└── docs/                 # Documentation and guides
```

## Quick Start

### On NixOS

```bash
sudo nixos-rebuild switch --flake .#pho3nixf1re-nixos
```

### On SteamOS

```bash
nix run home-manager/master -- switch --flake .#deck@steamdeck
```

### On macOS with nix-darwin

First time setup requires installing [nix-darwin](https://github.com/nix-darwin/nix-darwin#readme):

```bash
# Build and activate the darwin configuration
nix run nix-darwin -- switch --flake .#cvent-macos

# After first activation, use darwin-rebuild for subsequent builds
darwin-rebuild switch --flake .#cvent-macos
```

## Secrets

On a fresh installation, set up secrets from 1Password:

```bash
# Run the secrets setup script (one-time setup)
./setup-smb-secrets.sh
```

This script:
- Generates encryption keys from your SSH key
- Pulls SMB credentials from 1Password
- Creates an encrypted secrets file (stored in `secrets/`)

Once created, the Nix configuration reads secrets from the encrypted file. You
only need to re-run this script if the secrets change in 1Password.

For more details, see [SECRETS.md](docs/SECRETS.md).

## Environment Variables

### NIX_FLAKE_PATH

The `NIX_FLAKE_PATH` environment variable points to your nix-configs repository
location and is set in [modules/home/zsh/zsh.nix](modules/home/zsh/zsh.nix#L19).

**On fresh installations, this repository must be cloned to
`$HOME/nix-configs`** for the configuration to work correctly. This location is
hardcoded in the shell configuration and used throughout the system setup
process.

The variable is used by nix shell aliases (`nix-rebuild`, `nix-update`,
`nix-flake`, etc.) to locate the flake without requiring an explicit `--flake`
path argument on every command.

## Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Design principles & patterns
- **[AGENTS.md](docs/AGENTS.md)** - Instructions for AI/human agents
- **[SECRETS.md](docs/SECRETS.md)** - Secrets management with 1Password & sops-nix

- [Architecture & Design](docs/ARCHITECTURE.md) - Design principles and module patterns
- [Agent Instructions](docs/AGENTS.md) - Guidelines for contributing (human & AI)

## Available Configurations

**pho3nixf1re-nixos** (NixOS)
- Target: Full desktop system

**cvent-macos** (nix-darwin)
- Target: macOS work system

**deck@steamdeck** (Home Manager)
- Target: Steam Deck user config
