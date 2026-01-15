{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.starship = lib.mkIf config.programs.zsh.enable {
    enable = true;
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "auto";
      };
      display = {
        separator = " → ";
      };
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "display"
        "de"
        "wm"
        "terminal"
        "cpu"
        "gpu"
        "memory"
        "disk"
        "localip"
        "battery"
        "colors"
      ];
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 18;
        draw_bold_text_with_bright_colors = true;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.plasma = {
    enable = true;

    powerdevil = {
      AC = {
        powerButtonAction = "shutDown";
        autoSuspend = {
          action = "sleep";
          idleTimeout = 7200;
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
      lockOnResume = false;
      timeout = 10;
    };

    # FIXME: This does not seem to work.
    # krunner = {
    #   shortcuts.launch = "Meta+Space";
    # };
  };

  home.packages = with pkgs; [
    git
    git-credential-manager
    ripgrep
    jq
    libreoffice
    discord
    protonvpn-gui
  ];
}
