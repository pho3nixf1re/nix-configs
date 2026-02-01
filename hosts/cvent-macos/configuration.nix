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
      # TODO: Don't cleanup unmanaged brews. Change when all brews are managed with nix.
      cleanup = "none";
    };

    brews = [
      # Install zsh here as other programs expect it to be in Homebrew.
      "zsh"
    ];

    casks = [
      "1password"
      "1password/tap/1password-cli"
      "airfoil"
      "iterm2"
      "bartender"
    ];
  };
}
