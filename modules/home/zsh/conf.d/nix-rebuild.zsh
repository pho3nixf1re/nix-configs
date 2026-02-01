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
