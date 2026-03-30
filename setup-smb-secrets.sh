#!/usr/bin/env bash
# Setup script for sops-nix with SMB credentials from 1Password. Run this script
# to create or refresh encrypted SMB secrets when they change.
#
# Automatically runs setup-age-key.sh if the age key doesn't exist yet.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configuration - can be overridden with environment variables
SMB_CREDENTIALS_ITEM="${SMB_CREDENTIALS_ITEM:-op://Private/Feliciterra NAS - mturney}"
AGE_KEY_FILE="${AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

echo "🔐 SMB Secrets Setup (using 1Password)"
echo "======================================="
echo
echo "This fetches secrets from 1Password and encrypts them with sops."
echo "Encrypted secrets are SAFE to commit to git."
echo

# Ensure age key exists (delegates to setup-age-key.sh)
if [ ! -f "$AGE_KEY_FILE" ]; then
    echo "🔑 Age key not found at $AGE_KEY_FILE"
    echo "   Running setup-age-key.sh..."
    echo
    "$SCRIPT_DIR/setup-age-key.sh"
    echo
fi

# Verify age key is present after attempting setup
if [ ! -f "$AGE_KEY_FILE" ]; then
    echo "❌ Age key still not found at $AGE_KEY_FILE"
    echo "   Run ./setup-age-key.sh manually to debug."
    exit 1
fi

# Check for required tools
if ! command -v op &> /dev/null; then
    echo "❌ 1Password CLI not found."
    echo "   Install with: nix shell nixpkgs#_1password-cli"
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

# Step 1: Fetch SMB credentials from 1Password
echo
echo "🔐 Step 1: Fetching SMB credentials from 1Password..."

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

# Step 2: Create and encrypt the secrets file
echo
echo "🔒 Step 2: Creating encrypted secrets file..."
mkdir -p secrets

cat > "secrets/smb.yaml" << EOF
smb:
  feliciterra:
    env: |
      SMB_USERNAME=$USERNAME
      SMB_PASSWORD=$PASSWORD
EOF

# Encrypt the secrets in place
if command -v sops &> /dev/null; then
    sops -e -i secrets/smb.yaml
else
    nix shell nixpkgs#sops --quiet --command sops -e -i secrets/smb.yaml
fi

echo "✅ Secrets encrypted and saved to secrets/smb.yaml"

echo
echo "✨ Setup complete!"
echo
echo "✓ Age key at $AGE_KEY_FILE"
echo "✓ Secrets encrypted in secrets/smb.yaml (SAFE TO COMMIT)"
echo
echo "Next steps:"
echo "  1. Commit: git add secrets/smb.yaml && git commit -m 'Update encrypted secrets'"
echo "  2. Rebuild: sudo nixos-rebuild switch --flake .#pho3nixf1re-nixos"
echo "  3. Check mount: systemctl --user status smb-mount-feliciterra"
echo "  4. Verify: ls ~/mnt/feliciterra"
echo
echo "💡 To update secrets: edit with 'sops secrets/smb.yaml' or run this script again"
echo "📝 On new machines: Clone repo → ./setup-age-key.sh → rebuild"
echo "🔐 Encrypted secrets are safe to commit to git!"
