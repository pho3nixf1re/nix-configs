{
  # See https://nix-community.github.io/plasma-manager/options.xhtml
  programs.plasma = {
    enable = true;

    powerdevil = {
      AC = {
        powerButtonAction = "shutDown";
        autoSuspend = {
          action = "sleep";
          idleTimeout = 7200; # in seconds
        };
        turnOffDisplay = {
          idleTimeout = 3600; # in seconds
          idleTimeoutWhenLocked = 300; # in seconds
        };
        dimDisplay = {
          enable = true;
          idleTimeout = 1800; # in seconds
        };
        powerProfile = "performance";
        whenSleepingEnter = "standbyThenHibernate";
      };
    };

    input.keyboard = {
      layouts = [
        {
          layout = "us";
          variant = "dvorak";
          displayName = "dv";
        }
        {
          layout = "us";
          displayName = "qw";
        }
      ];
      options = [ "caps:escape" ];
      numlockOnStartup = "on";
    };

    kscreenlocker = {
      lockOnResume = true;
      autoLock = false;
      # timeout = 120; # in minutes

      appearance = {
        showMediaControls = true;
        alwaysShowClock = true;
        wallpaperPictureOfTheDay.provider = "apod";
      };
    };

    kwin = {
      effects = {
        hideCursor = {
          enable = true;
          hideOnInactivity = 15; # in seconds
          hideOnTyping = true;
        };
      };
    };

    shortcuts = {
      kwin = {
        "Launch" = "Meta+Space";
      };
      kwin = {
        "Switch to Next Keyboard Layout" = "Meta+Alt+Space";
      };
    };
  };

  xdg.configFile = builtins.listToAttrs (
    builtins.map (filename: {
      name = "autostart/${filename}";
      value = {
        source = ./autostart/${filename};
      };
    }) (builtins.attrNames (builtins.readDir ./autostart))
  );
}
