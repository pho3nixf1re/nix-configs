{
  homebrew = {
    brews = [
      # Install zsh here as other programs expect it to be in Homebrew.
      "zsh"

      "circleci"
    ];

    casks = [
      # Used by Claude Co-work and other automation tools.
      "google-chrome"

      "firefox"
      "1password"
      "1password-cli"

      "alfred"
      # "bartender"
      # "steermouse"

      "airfoil"
      "qobuz"

      "iterm2"
      "dash"
      "bruno"
      "switchhosts"

      "dbeaver-community"
      "tableplus"
    ];

    masApps = {
      "DaisyDisk" = 411643860;
      "Developer" = 640199958;
      "GarageBand" = 682658836;
      "Gifski" = 1351639930;
      "iMovie" = 408981434;
      "Keka" = 470158793;
      "Keynote" = 361285480;
      "Magnet" = 441258766;
      "Microsoft Remote Desktop" = 1295203466;
      "Numbers" = 361304891;
      "Pages" = 361309726;
      "Pixelmator Pro" = 1289583905;
      "WiFi Explorer" = 494803304;
      "Xcode" = 497799835;
    };
  };
}
