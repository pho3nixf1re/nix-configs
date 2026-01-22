#!/usr/bin/env bash
# Setup script for sops-nix with SMB credentials from 1Password. Run this script
# on each new machine setup, or to refresh secrets when they change

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configuration - can be overridden with environment variables
SSH_KEY_ITEM="${SSH_KEY_ITEM:-op://Private/Nix Secrets Key/private key}"
SMB_CREDENTIALS_ITEM="${SMB_CREDENTIALS_ITEM:-op://Private/Feliciterra NAS - mturney}"

echo "🔐 SMB Secrets Setup (using 1Password SSH Agent)"
echo "================================================"
echo
echo "This fetches secrets from 1Password and encrypts them with sops."
echo "Encrypted secrets are SAFE to commit to git."
echo

# Check for required tools
if ! command -v op &> /dev/null; then
    echo "❌ 1Password CLI not found."
    echo "   Install with: nix-shell -p _1password"
    exit 1
fi

# Check if 1Password is signed in
if ! op account list &> /dev/null 2>&1; then
    echo "🔓 Unlocking 1Password (use your Yubikey or master password)..."
    eval $(op signin)
fi

# Check if this is an update
if [ -f secrets/smb.yaml ]; then
    echo "⚠️  Existing secrets found. This will update them."
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "⏭️  Aborted."
        exit 0
    fi
fi

echo
echo "📋 Step 1: Getting SSH key from 1Password..."

# Create temporary file for SSH key
SSH_KEY_PATH=$(mktemp)
trap "rm -f $SSH_KEY_PATH" EXIT

# Fetch SSH private key from 1Password
if ! op read "$SSH_KEY_ITEM" > "$SSH_KEY_PATH" 2>/dev/null; then
    echo "❌ Failed to fetch SSH key from 1Password"
    echo "   Expected item: $SSH_KEY_ITEM"
    echo ""
    echo "💡 Available SSH keys in 1Password:"
    op item list --categories "SSH Key" --format json 2>/dev/null | jq -r '.[] | "   - \(.title)"' || echo "   (install jq to see list)"
    echo ""
    echo "Update \$SSH_KEY_ITEM with the correct path."
    exit 1
fi

chmod 600 "$SSH_KEY_PATH"
echo "✅ SSH key retrieved from 1Password"

# Step 2: Generate age key from SSH key
echo
echo "🔑 Step 2: Generating age key from 1Password SSH key..."
mkdir -p ~/.config/sops/age

# Check if key needs format conversion (PKCS#8 to OpenSSH)
if grep -q "BEGIN PRIVATE KEY" "$SSH_KEY_PATH"; then
    echo "   Converting key from PKCS#8 to OpenSSH format..."

    # Create a new temporary file for the converted key
    OPENSSH_KEY=$(mktemp)
    trap "rm -f $SSH_KEY_PATH $OPENSSH_KEY" EXIT

    # Use ssh-keygen to convert format - without -m it defaults to OpenSSH format
    # -P "" = old passphrase empty, -N "" = new passphrase empty, -q = quiet
    ssh-keygen -p -P "" -N "" -f "$SSH_KEY_PATH" -q || {
        echo "❌ Failed to convert key format"
        exit 1
    }

    echo "   ✓ Key converted to OpenSSH format"
fi

# Auto-detect if we need nix-shell
# Temporarily allow errors to surface key format issues.
set +e
if command -v ssh-to-age &> /dev/null; then
    AGE_KEY_OUTPUT=$(ssh-to-age -private-key -i "$SSH_KEY_PATH" 2>&1)
    EXIT_CODE=$?
else
    AGE_KEY_OUTPUT=$(nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i '$SSH_KEY_PATH'" 2>&1)
    EXIT_CODE=$?
fi
# Re-enable exit on error for cleaner script behavior.
set -e

# Check if conversion was successful
if [ $EXIT_CODE -ne 0 ]; then
    echo "❌ Failed to convert SSH key to age key (exit code: $EXIT_CODE)"
    echo "   Output: $AGE_KEY_OUTPUT"
    echo ""
    echo "💡 Make sure the SSH key is in the correct format (ed25519 or RSA)"
    exit 1
fi

if [ -z "$AGE_KEY_OUTPUT" ]; then
    echo "❌ ssh-to-age produced no output"
    echo "   The SSH key may be in an unsupported format"
    exit 1
fi

echo "$AGE_KEY_OUTPUT" > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
echo "✅ Age key generated and saved"

# Get age public key
if command -v age-keygen &> /dev/null; then
    AGE_PUBLIC_KEY=$(age-keygen -y ~/.config/sops/age/keys.txt)
else
    AGE_PUBLIC_KEY=$(nix-shell -p age --run "age-keygen -y ~/.config/sops/age/keys.txt")
fi
echo "   Public key: $AGE_PUBLIC_KEY"

# Step 3: Update .sops.yaml
echo
echo "📝 Step 3: Updating .sops.yaml..."

cat > .sops.yaml << EOF
keys:
  - &pho3nixf1re $AGE_PUBLIC_KEY
creation_rules:
  - path_regex: secrets/smb\.yaml\$
    key_groups:
      - age:
          - *pho3nixf1re
EOF

echo "✅ .sops.yaml updated"

# Step 4: Fetch SMB credentials from 1Password
echo
echo "🔐 Step 4: Fetching SMB credentials from 1Password..."

USERNAME=$(op read "$SMB_CREDENTIALS_ITEM/username")
if [ -z "$USERNAME" ]; then
    echo "❌ Failed to fetch username from 1Password"
    echo "   Expected item: $SMB_CREDENTIALS_ITEM/username"
    exit 1
fi

PASSWORD=$(op read "$SMB_CREDENTIALS_ITEM/password")
if [ -z "$PASSWORD" ]; then
    echo "❌ Failed to fetch password from 1Password"
    echo "   Expected item: $SMB_CREDENTIALS_ITEM/password"
    exit 1
fi

echo "✅ Credentials retrieved"

# Step 5: Create and encrypt the secrets file
echo
echo "🔒 Step 5: Creating encrypted secrets file..."
mkdir -p secrets

cat > "secrets/smb.yaml" << EOF
smb:
  feliciterra:
    credentials: |
      username=$USERNAME
      password=$PASSWORD
      domain=WORKGROUP
EOF

# Encrypt the secrets in place
if command -v sops &> /dev/null; then
    sops -e -i secrets/smb.yaml
else
    nix-shell -p sops --run "sops -e -i secrets/smb.yaml"
fi

echo "✅ Secrets encrypted and saved to secrets/smb.yaml"

echo
echo "✨ Setup complete!"
echo
echo "✓ SSH key fetched from 1Password (never stored on disk)"
echo "✓ Age key derived and saved to ~/.config/sops/age/keys.txt"
echo "✓ Secrets encrypted in secrets/smb.yaml (SAFE TO COMMIT)"
echo
echo "Next steps:"
echo "  1. Commit: git add secrets/smb.yaml .sops.yaml && git commit -m 'Add encrypted secrets'"
echo "  2. Rebuild: sudo nixos-rebuild switch --flake .#pho3nixf1re-nixos"
echo "  3. Check mount: systemctl --user status smb-mount-feliciterra"
echo "  4. Verify: ls ~/mnt/feliciterra"
echo
echo "💡 To update secrets: edit with 'sops secrets/smb.yaml' or run this script again"
echo "📝 On new machines: Clone repo → run this script → rebuild"
echo "🔐 Encrypted secrets are safe to commit to git!"
