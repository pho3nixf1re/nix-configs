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
      autohide-delay = 0.5;
      orientation = "bottom";
      show-recents = false;
      tilesize = 48;
      largesize = 52;
      magnification = true;
      show-process-indicators = true;
    };
    finder = {
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXEnableExtensionChangeWarning = false;
      # Set Finder view to list by default.
      FXPreferredViewStyle = "Nlsv";
      FXRemoveOldTrashItems = true;
      # Search the current folder by default.
      FXDefaultSearchScope = "SCcf";
      NewWindowTarget = "Home";
      ShowExternalHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = false;
      CreateDesktop = false;
    };
    menuExtraClock = {
      FlashDateSeparators = false;
      IsAnalog = false;
      Show24Hour = true;
      ShowAMPM = false;
      ShowDayOfMonth = false;
      ShowDayOfWeek = true;
      ShowDate = 1;
      ShowSeconds = false;
    };

    controlcenter = {
      AirDrop = false;
      BatteryShowPercentage = true;
      Bluetooth = false;
      Display = false;
      FocusModes = false;
      NowPlaying = true;
      Sound = false;
    };

    NSGlobalDomain = {
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Automatic";
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };

  # Set ZDOTDIR so zsh looks in XDG config location.
  environment.variables = {
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
