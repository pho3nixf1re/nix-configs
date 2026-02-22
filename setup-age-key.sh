#!/usr/bin/env bash
# Derives an age key from a 1Password SSH key for use with sops-nix.
# Run on new machines to enable secret decryption, or to regenerate the key.
#
# Usage:
#   ./setup-age-key.sh          # Only creates key if missing
#   ./setup-age-key.sh --force  # Recreates key even if it exists

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configuration - can be overridden with environment variables
SSH_KEY_ITEM="${SSH_KEY_ITEM:-op://Private/Nix Secrets Key/private key}"
AGE_KEY_FILE="${AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

FORCE=false
if [[ "${1:-}" == "--force" ]]; then
    FORCE=true
fi

# Skip if key already exists (unless --force)
if [ -f "$AGE_KEY_FILE" ] && [ "$FORCE" = false ]; then
    echo "✅ Age key already exists at $AGE_KEY_FILE (use --force to regenerate)"
    exit 0
fi

echo "🔑 Age Key Setup (from 1Password SSH key)"
echo "==========================================="
echo

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
echo "🔑 Step 2: Generating age key from SSH key..."
mkdir -p "$(dirname "$AGE_KEY_FILE")"

# Check if key needs format conversion (PKCS#8 to OpenSSH).
# 1Password exports ed25519 keys in PKCS#8 format (BEGIN PRIVATE KEY), but
# ssh-to-age requires OpenSSH format (BEGIN OPENSSH PRIVATE KEY).
# ssh-keygen -p without -m rewrites the key in native OpenSSH format.
# nixpkgs openssh is used for a consistent modern version across macOS and Linux.
if grep -q "BEGIN PRIVATE KEY" "$SSH_KEY_PATH"; then
    echo "   Converting key from PKCS#8 to OpenSSH format..."

    CONVERTED_KEY=$(mktemp)
    chmod 600 "$CONVERTED_KEY"
    cp "$SSH_KEY_PATH" "$CONVERTED_KEY"
    trap "rm -f $SSH_KEY_PATH $CONVERTED_KEY" EXIT

    # ssh-keygen -p reads PKCS#8 and rewrites in native OpenSSH format (no -m flag).
    # Use nixpkgs openssh for a consistent modern version across macOS and Linux.
    CONV_OUT=$(nix shell nixpkgs#openssh --quiet --command \
        ssh-keygen -p -P "" -N "" -f "$CONVERTED_KEY" 2>&1) && CONV_RC=0 || CONV_RC=$?
    if [ $CONV_RC -ne 0 ]; then
        echo "❌ Failed to convert key from PKCS#8 to OpenSSH format"
        echo "   Output: $CONV_OUT"
        exit 1
    fi

    echo "   ✓ Key converted to OpenSSH format"
    SSH_KEY_PATH="$CONVERTED_KEY"
fi

# Auto-detect if we need nix shell
# Temporarily allow errors to surface key format issues.
set +e
if command -v ssh-to-age &> /dev/null; then
    AGE_KEY_OUTPUT=$(ssh-to-age -private-key -i "$SSH_KEY_PATH" 2>&1)
    EXIT_CODE=$?
else
    AGE_KEY_OUTPUT=$(nix shell nixpkgs#ssh-to-age --quiet --command ssh-to-age -private-key -i "$SSH_KEY_PATH" 2>/dev/null)
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

echo "$AGE_KEY_OUTPUT" > "$AGE_KEY_FILE"
chmod 600 "$AGE_KEY_FILE"
echo "✅ Age key generated and saved to $AGE_KEY_FILE"

# Get age public key
if command -v age-keygen &> /dev/null; then
    AGE_PUBLIC_KEY=$(age-keygen -y "$AGE_KEY_FILE")
else
    AGE_PUBLIC_KEY=$(nix shell nixpkgs#age --quiet --command age-keygen -y "$AGE_KEY_FILE")
fi
echo "   Public key: $AGE_PUBLIC_KEY"

echo
echo "✨ Age key setup complete!"
echo
echo "✓ SSH key fetched from 1Password (never stored on disk)"
echo "✓ Age key derived and saved to $AGE_KEY_FILE"
echo
echo "Next steps:"
echo "  • Rebuild to decrypt existing secrets: sudo nixos-rebuild switch --flake .#pho3nixf1re-nixos"
echo "  • Or update secrets: ./setup-smb-secrets.sh"
echo "  • To regenerate: ./setup-age-key.sh --force"
