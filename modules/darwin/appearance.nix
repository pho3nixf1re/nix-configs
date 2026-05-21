{ pkgs, ... }:

let
  wallpaper = pkgs.fetchurl {
    url = "https://files.feliciterra.com/public/559d3580ba88/dav/Space_Wallpaper_Desktop.webp";
    hash = "sha256-q/oL1JCoR/cYv+3tgpvcVEKh4s5O0rV5hwxJhOX+tWs=";
  };
in
{
  # system.activationScripts.postUserActivation.text = ''
  #   osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"${wallpaper}\""
  # '';

  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.25;
      orientation = "bottom";
      show-recents = false;
      tilesize = 48;
      largesize = 60;
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
      # Disables the press-and-hold feature for keys in favor of key repeat.
      ApplePressAndHoldEnabled = false;
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };
}
