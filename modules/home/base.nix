{ pkgs, ... }:

{
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

  # Allows home-manager to manage xdg settings and config files.
  xdg.enable = true;

  home.packages = with pkgs; [
    # CLI tools.
    git
    git-credential-manager
    ripgrep
    jq
    nnn

    # Desktop apps.
    libreoffice
    discord
    protonvpn-gui

    # Needed for OH-MY-ZSH plugins.
    autojump
    tmux

    # Runtimes.
    nodejs
    python3

    # nix related
    #
    # It provides the command `nom` works just like `nix`
    # with more detailed log output.
    nix-output-monitor
  ];
}
