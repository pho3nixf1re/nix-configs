nix-update() {
  local update_latest=0
  local update_system=0
  local update_homebrew=0
  local update_darwin=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        cat << EOF
Usage: nix-update [OPTIONS]

Update flake inputs for nix configurations.

OPTIONS:
   --latest      Update nixpkgs-latest, home-manager, and nixpkgs-xr (apps, VR packages)
   --system      Update nixpkgs (system channel: kernel, Plasma)
   --homebrew    Update homebrew-core, homebrew-cask, and nix-homebrew
   --darwin      Update nix-darwin
   -h, --help    Show this help message

If no options are specified, defaults to --latest.
Multiple options can be combined: nix-update --latest --darwin
EOF
        return 0
        ;;
      --latest)   update_latest=1;   shift ;;
      --system)   update_system=1;   shift ;;
      --homebrew) update_homebrew=1; shift ;;
      --darwin)   update_darwin=1;   shift ;;
      *) echo "Unknown option: $1" >&2; return 1 ;;
    esac
  done

  # Default to --latest if no flags given
  if [[ $update_latest -eq 0 && $update_system -eq 0 && $update_homebrew -eq 0 && $update_darwin -eq 0 ]]; then
    update_latest=1
  fi

  if [[ $update_latest -eq 1 ]]; then
    echo "Updating nixpkgs-latest, home-manager, and nixpkgs-xr (apps, VR packages)..."
    nix flake update nixpkgs-latest home-manager nixpkgs-xr --flake "$NIX_FLAKE_PATH"
  fi

  if [[ $update_system -eq 1 ]]; then
    echo "Updating nixpkgs (system channel: kernel, Plasma)..."
    nix flake update nixpkgs --flake "$NIX_FLAKE_PATH"
  fi

  if [[ $update_homebrew -eq 1 ]]; then
    echo "Updating homebrew-core, homebrew-cask, and nix-homebrew..."
    nix flake update homebrew-core homebrew-cask nix-homebrew --flake "$NIX_FLAKE_PATH"
  fi

  if [[ $update_darwin -eq 1 ]]; then
    echo "Updating nix-darwin..."
    nix flake update nix-darwin --flake "$NIX_FLAKE_PATH"
  fi
}

# nix-dev function to support arguments like: nix-dev database-tools --command zsh
nix-dev() {
  if [[ $# -eq 0 ]]; then
    local system
    system="$(nix eval --impure --raw --expr builtins.currentSystem 2>/dev/null)" || {
      echo "Error: unable to determine current Nix system" >&2
      return 1
    }

    echo "Available dev shells for ${system}:"
    if ! nix eval --raw "$NIX_FLAKE_PATH#devShells.${system}" --apply 'shells: builtins.concatStringsSep "\n" (builtins.attrNames shells)'; then
      echo "(none found)"
      return 1
    fi
    return 0
  fi

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
    local darwin_host
    case "$USER" in
      pho3nixf1re) darwin_host="pho3nixf1re-macos" ;;
      mturney)     darwin_host="cvent-macos" ;;
      *) echo "Error: no Darwin config for user '$USER'" >&2; return 1 ;;
    esac
    sudo darwin-rebuild switch --flake "$NIX_FLAKE_PATH#${darwin_host}"
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
