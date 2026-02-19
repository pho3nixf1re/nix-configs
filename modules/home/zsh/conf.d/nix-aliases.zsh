nix-update = nix flake update --flake "$NIX_FLAKE_PATH"

# nix-dev function to support arguments like: nix-dev database-tools --command zsh
nix-dev() {
  local flake_ref="$1"
  shift
  nix develop "$NIX_FLAKE_PATH#$flake_ref" "$@"
}

# nix-flake function to pass arguments properly
nix-flake() { nix flake "$@" --flake "$NIX_FLAKE_PATH"; }

nix-rebuild() {
  if command -v darwin-rebuild &> /dev/null; then
    sudo darwin-rebuild switch --flake "$NIX_FLAKE_PATH#cvent-macos"
  elif command -v nixos-rebuild &> /dev/null; then
    sudo nixos-rebuild switch --flake "$NIX_FLAKE_PATH#pho3nixf1re-nixos"
  else
    echo "Error: neither darwin-rebuild nor nixos-rebuild found" >&2
    return 1
  fi
}
