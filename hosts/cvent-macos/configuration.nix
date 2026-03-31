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

  # This is needed to support Netskope MITM interception.
  nix.settings.ssl-cert-file = "/Users/mturney/.config/ssl/nscacert.pem";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  nixpkgs.hostPlatform = "aarch64-darwin";

  # Primary user for system defaults and homebrew
  system.primaryUser = "mturney";

  # User configuration
  users.users.mturney = {
    name = "mturney";
    home = "/Users/mturney";
  };

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  environment.variables = {
    # Use XDG config location for zsh. Default is `$HOME/.zshrc` on MacOS.
    ZDOTDIR = "$HOME/.config/zsh";
  };

  # Maybe we don't need this with home-manager?
  # systemPackages = with pkgs; [
  # ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      # Don't cleanup unmanaged brews.
      cleanup = "none";
    };
  };
}
