{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kdePackages.konsole
    kdePackages.yakuake
  ];

  # See https://nix-community.github.io/plasma-manager/options.xhtml
  programs.plasma = {
    enable = true;

    # Times and timeouts are in seconds, unless otherwise noted.

    powerdevil = {
      AC = {
        powerButtonAction = "shutDown";
        autoSuspend = {
          action = "nothing";
          # idleTimeout = 7200;
        };
        turnOffDisplay = {
          idleTimeout = 3600;
          idleTimeoutWhenLocked = 300;
        };
        dimDisplay = {
          enable = true;
          idleTimeout = 1800;
        };
        powerProfile = "performance";
        whenSleepingEnter = "standby";
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
          hideOnInactivity = 15;
          hideOnTyping = true;
        };
      };
    };

    shortcuts = {
      "services/org.kde.krunner.desktop"._launch = [
        "Search"
        "Meta+Space"
      ];
      yakuake.toggle-window-state = "Ctrl+Space";
      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Meta+Alt+Shift";
    };

    configFile = {
      kwinrc.TabBox = {
        HighlightWindows = false;
        LayoutName = "big_icons";
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
