{ pkgs, ... }:

{
  # Nix configuration
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Auto-upgrade nix package
  nix.package = pkgs.nix;

  nixpkgs.config.allowUnfree = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Primary user for system defaults and homebrew
  system.primaryUser = "pho3nixf1re";

  # User configuration
  users.users.pho3nixf1re = {
    name = "pho3nixf1re";
    home = "/Users/pho3nixf1re";
  };

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  environment.variables = {
    # Use XDG config location for zsh. Default is `$HOME/.zshrc` on MacOS.
    ZDOTDIR = "$HOME/.config/zsh";
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      # Don't cleanup unmanaged brews.
      cleanup = "none";
    };
  };
}
