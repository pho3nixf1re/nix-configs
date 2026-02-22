# Secrets Management

This repository uses **sops-nix** with **1Password** as the source of truth for secrets, including SSH keys.

## Philosophy

- **1Password** stores everything: secrets AND SSH keys (source of truth)
- **Age keys derived from 1Password SSH keys** on each machine
- **Local encrypted files** are generated from 1Password on each machine
- **Nothing secret is committed** to git (even encrypted files are gitignored)
- **Key setup is separate from secret encryption** — new machines only need the age key to decrypt
- **Setup scripts are idempotent** — safe to re-run at any time

## Initial Setup (New Machine)

### Prerequisites

1. **1Password CLI** installed and configured
   ```bash
   nix-shell -p _1password
   ```

2. **SSH key stored in 1Password**
   - Create an SSH key in 1Password (or import existing one)
   - Note the item name/path (e.g., "SSH Key - NixOS")
   - Default path in script: `op://Private/Nix Secrets Key/private key`
   - Override with environment variable: `SSH_KEY_ITEM="op://Personal/Your Key/private key"`

3. **SMB credentials stored in 1Password**
   - Create or use existing 1Password item with username and password fields
   - Default item in script: `op://Private/Feliciterra NAS - mturney`
   - Override with environment variable: `SMB_CREDENTIALS_ITEM="op://Personal/Your NAS"`

### Setup Steps

There are two scripts that can be run independently:

- **`setup-age-key.sh`** — Derives an age key from your 1Password SSH key (required on every machine)
- **`setup-smb-secrets.sh`** — Fetches SMB credentials from 1Password and encrypts them with sops

#### New Machine (decrypt existing secrets)

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd nix-configs
   ```

2. **Generate the age key**
   ```bash
   # Use default SSH key path
   ./setup-age-key.sh

   # Or override with a custom 1Password path
   SSH_KEY_ITEM="op://Personal/My SSH Key/private key" ./setup-age-key.sh
   ```

   This will:
   - Prompt you to unlock 1Password (Yubikey/master password)
   - Fetch your SSH private key from 1Password
   - Derive an age encryption key and save it to `~/.config/sops/age/keys.txt`
   - Clean up all temporary files (SSH key never stored on disk)

3. **Build your configuration**
   ```bash
   sudo nixos-rebuild switch --flake .#pho3nixf1re-nixos
   ```

#### Create or Update Encrypted Secrets

When secrets need to be created for the first time or refreshed after changing in 1Password:

```bash
# Use default paths
./setup-smb-secrets.sh

# Or override with custom paths
SMB_CREDENTIALS_ITEM="op://Personal/My NAS" ./setup-smb-secrets.sh
```

This will:
- Automatically run `setup-age-key.sh` if no age key exists yet
- Update `.sops.yaml` with your public key
- Fetch SMB credentials from 1Password
- Create `secrets/smb.yaml` locally (encrypted, gitignored)

## Using 1Password SSH Agent (Optional)

For even better integration, enable 1Password's SSH agent:

1. **In 1Password settings:**
   - Turn on "Use the SSH agent"
   - Turn on "Display key names when authorizing connections"

2. **Add to your profile:**
   Already configured in this repo! See [modules/home/ssh/ssh.nix](../modules/home/ssh/ssh.nix)

Now git operations and SSH connections will use 1Password's agent with biometric unlock!

## Updating Secrets

When credentials change in 1Password, re-run the secrets script:

```bash
./setup-smb-secrets.sh
```

Then rebuild your configuration to apply the changes.

To regenerate the age key (e.g., if the SSH key changed in 1Password):

```bash
./setup-age-key.sh --force
```

## How It Works

```
┌─────────────────┐
│   1Password     │  ← Source of truth
│                 │     - SMB credentials
│  [Yubikey lock] │     - SSH private key
└────────┬────────┘
         │
         │ op read (requires unlock)
         ↓
┌───────────────────────┐
│  setup-age-key.sh     │  ← Run once per machine
│                       │
│  1. Fetch SSH key     │
│  2. Derive age key    │───→ ~/.config/sops/age/keys.txt
│  3. Cleanup SSH key   │     (derived from SSH key)
└───────────────────────┘

┌───────────────────────┐
│ setup-smb-secrets.sh  │  ← Run to create/update secrets
│                       │
│  (auto-calls age key  │
│   script if needed)   │
│                       │
│  1. Update .sops.yaml │
│  2. Fetch SMB creds   │
│  3. Encrypt secrets   │
└───────────┬───────────┘
            ↓
┌──────────────────┐
│ secrets/smb.yaml │  ← Encrypted, local only, gitignored
└────────┬─────────┘
         │
         │ sops-nix (automatic at build time)
         │ (decrypts using age key)
         ↓
┌───────────────────┐
│ /run/user/.../    │  ← Decrypted credentials at runtime
│ smb-credentials   │
└───────────────────┘
         │
         ↓
┌───────────────────┐
│ SMB mount service │  Uses credentials to mount share
└───────────────────┘
```

## Benefits Over Traditional SSH Keys

| Traditional | 1Password SSH |
|------------|---------------|
| Keys on disk | Keys in encrypted vault |
| File permissions for security | Biometric unlock |
| Manual backup/sync | Automatic sync across devices |
| No audit trail | Full audit log |
| Lost laptop = exposed keys | Lost laptop = keys still safe |

## Adding New Secrets

1. Store the secret in 1Password
2. Create a new `setup-<name>-secrets.sh` script (or extend an existing one)
3. Have it call `./setup-age-key.sh` if `$AGE_KEY_FILE` doesn't exist (same pattern as `setup-smb-secrets.sh`)
4. Add it to the sops YAML structure
5. Configure sops-nix module to use it

## On New Machines

The workflow is:
1. Clone repo
2. Install 1Password CLI (if not already available)
3. Run `./setup-age-key.sh` (requires 1Password access with Yubikey)
4. Build configuration — sops-nix decrypts existing secrets using the age key

You only need to run `./setup-smb-secrets.sh` if the encrypted secrets file needs to be created or updated.

The age key never leaves your machine and is never committed to git.

**No SSH key setup required!** Everything comes from 1Password.

## Security Notes

- **SSH keys never touch disk unencrypted** (fetched from 1Password, used, then deleted)
- **Age keys are derived** from your 1Password SSH key
- **Secrets are encrypted** with your age public key (derived from SSH)
- **Only your private key can decrypt** them
- **1Password is the single source of truth** for everything
- **Yubikey or biometric unlock** protects all operations
- **If SSH key changes in 1Password**, re-run `./setup-age-key.sh --force` to regenerate age key

## Troubleshooting

### "SSH key not found in 1Password"

List your SSH keys and use the environment variable override:
```bash
op item list --categories "SSH Key"

# Use environment variable to specify your key
SSH_KEY_ITEM="op://YourVault/Your SSH Key/private key" ./setup-age-key.sh
```

Alternatively, you can edit the default in `setup-age-key.sh`.

### "Failed to fetch credentials from 1Password"

Ensure your 1Password item has `username` and `password` fields:
```bash
# List your items to find the correct path
op item list

# Use environment variable to specify your item
SMB_CREDENTIALS_ITEM="op://YourVault/Your NAS Item" ./setup-smb-secrets.sh
```

### "Failed to unlock 1Password"

Ensure your Yubikey is plugged in or master password is ready.

### "Age key generation failed"

Ensure your SSH key in 1Password is in OpenSSH format (ed25519 or RSA).
