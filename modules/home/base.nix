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
      ripgrep # A fast search tool for the terminal, `rg`.
      jq # For processing JSON data in the terminal.
      nnn # A terminal file manager.
      tree # For visualizing directory structures.
      eza # A modern replacement for ls.
      gum # For interactive CLI prompts.

      # Process monitoring tools.
      htop
      watch
      pstree

      # Networking tools.
      httpie
      curl
      wget
      sshfs

      # Needed for OH-MY-ZSH plugins.
      autojump
      tmux

      # Compression tools.
      unzip
      p7zip

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
