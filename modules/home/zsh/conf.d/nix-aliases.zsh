nix-update() {
  local update_latest=0
  local update_system=0
  local update_homebrew=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --latest)   update_latest=1;   shift ;;
      --system)   update_system=1;   shift ;;
      --homebrew) update_homebrew=1; shift ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  # Default to --latest if no flags given
  if [[ $update_latest -eq 0 && $update_system -eq 0 && $update_homebrew -eq 0 ]]; then
    update_latest=1
  fi

  if [[ $update_latest -eq 1 ]]; then
    echo "Updating nixpkgs-latest and home-manager (apps, home-manager packages)..."
    nix flake update nixpkgs-latest home-manager --flake "$NIX_FLAKE_PATH"
  fi

  if [[ $update_system -eq 1 ]]; then
    echo "Updating nixpkgs (system channel: kernel, Plasma)..."
    nix flake update nixpkgs --flake "$NIX_FLAKE_PATH"
  fi

  if [[ $update_homebrew -eq 1 ]]; then
    echo "Updating homebrew-core and homebrew-cask..."
    nix flake update homebrew-core homebrew-cask --flake "$NIX_FLAKE_PATH"
  fi
}

# nix-dev function to support arguments like: nix-dev database-tools --command zsh
nix-dev() {
  local flake_ref="$1"
  shift
  nix develop "$NIX_FLAKE_PATH#$flake_ref" "$@"
}

# nix-flake function to pass arguments properly
nix-flake() { nix flake "$@" --flake "$NIX_FLAKE_PATH"; }

nix-apply() {
  local mode="switch"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --boot) mode="boot"; shift ;;
      --test) mode="test"; shift ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  if command -v darwin-rebuild &> /dev/null; then
    if [[ "$mode" != "switch" ]]; then
      echo "Error: --${mode} is only supported on NixOS" >&2
      return 1
    fi
    sudo darwin-rebuild switch --flake "$NIX_FLAKE_PATH#cvent-macos"
  elif command -v nixos-rebuild &> /dev/null; then
    sudo nixos-rebuild "$mode" --flake "$NIX_FLAKE_PATH#pho3nixf1re-nixos"
  elif grep -qi "steamos" /etc/os-release 2>/dev/null; then
    if [[ "$mode" != "switch" ]]; then
      echo "Error: --${mode} is only supported on NixOS" >&2
      return 1
    fi
    if command -v home-manager &> /dev/null; then
      home-manager switch --flake "$NIX_FLAKE_PATH#deck"
    else
      nix run nixpkgs#home-manager -- switch --flake "$NIX_FLAKE_PATH#deck"
    fi
  else
    echo "Error: unsupported platform" >&2
    return 1
  fi
}
