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

  # The platform the configuration will be used on.
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

  # System defaults
  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
      show-recents = false;
      tilesize = 48;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };

  # Set ZDOTDIR so zsh looks in XDG config location.
  environment.variables = {
    ZDOTDIR = "$HOME/.config/zsh";
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      # TODO: Don't cleanup unmanaged brews. Change when all brews are managed with nix.
      cleanup = "none";
    };

    taps = [
      "1password/tap"
    ];

    brews = [
      "zsh"
    ];

    casks = [
      "1password"
      "1password/tap/1password-cli"
      "airfoil"
      "iterm2"
    ];
  };
}
