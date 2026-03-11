{
  pkgs,
  config,
  lib,
  ...
}:

let
  wallpaper = pkgs.fetchurl {
    url = "https://files.feliciterra.com/public/51dab3d6d35e/dav/Galaxy_3.png";
    hash = "sha256-ug7hhF4Tp9upxF+E6HjCVRnYtBREOAJ0MlMJwtaIvw0=";
  };
in
{
  home.packages = with pkgs; [
    kdePackages.konsole
    kdePackages.yakuake
  ];

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  # Override the package's .desktop file to use Exec directly with the full
  # store path, disabling DBusActivatable. On non-NixOS (e.g. SteamOS), the
  # Nix D-Bus service files are not registered with the session daemon so
  # DBusActivatable fails with ServiceUnknown.
  # Written directly because xdg.desktopEntries doesn't reliably work on
  # non-NixOS systems.
  xdg.dataFile."applications/org.kde.yakuake.desktop" = lib.mkIf config.targets.genericLinux.enable {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Yakuake
      GenericName=Drop-down Terminal
      Comment=A drop-down terminal emulator based on KDE Konsole technology.
      Exec=${pkgs.kdePackages.yakuake}/bin/yakuake
      Icon=yakuake
      Categories=Qt;KDE;System;TerminalEmulator;
      Terminal=false
      StartupNotify=false
    '';
  };

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
        wallpaper = wallpaper;
      };
    };

    workspace.wallpaper = wallpaper;

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

  xdg.configFile."autostart" = {
    source = ./autostart;
    recursive = true;
  };
}
