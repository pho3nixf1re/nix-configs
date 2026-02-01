{
  pkgs,
  lib,
  ...
}:

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

  programs.gpg.enable = true;

  # Allows home-manager to manage xdg settings and config files.
  xdg.enable = true;

  home.packages =
    with pkgs;
    [
      # General CLI tools.
      ripgrep
      jq
      nnn
      tree
      eza

      # Process monitoring tools.
      htop
      watch
      pstree

      # Networking tools.
      httpie
      curl

      # Needed for OH-MY-ZSH plugins.
      autojump
      tmux

      # nix related
      #
      # It provides the command `nom` works just like `nix`
      # with more detailed log output.
      nix-output-monitor
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # Linux-only as MacOS has osxkeychain built-in.
      pkgs.git-credential-manager
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      pkgs.pinentry_mac
    ];
}
