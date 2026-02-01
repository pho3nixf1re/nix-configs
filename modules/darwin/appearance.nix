{
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
}
