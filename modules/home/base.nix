{
  pkgs,
  lib,
  stdenv,
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
  services.gpg-agent = {
    enable = true;
    # Conflicts with ssh-agent and git signing.
    enableSshSupport = false;
    enableBashIntegration = true;
    pinentryPackage = lib.mkIf pkgs.stdenv.isLinux pkgs.pinentry-qt;
  };

  # Allows home-manager to manage xdg settings and config files.
  xdg.enable = true;

  home.packages =
    with pkgs;
    [
      # General CLI tools.
      gh
      ripgrep
      jq
      nnn
      tree
      eza
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
    ++ lib.optionals stdenv.isLinux [
      # Linux-only as MacOS has osxkeychain built-in.
      git-credential-manager
    ]
    ++ lib.optionals stdenv.isDarwin [
      pinentry-mac
    ];
}
