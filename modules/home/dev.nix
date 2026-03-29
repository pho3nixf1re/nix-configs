{ pkgs, ... }:

{
  programs.vscode.enable = true;

  programs.lazygit.enable = true;

  home.packages = with pkgs; [
    # Development runtimes.
    nodejs
    python3
    python3.pkgs.pip

    # Nix development tools.
    nixfmt
    nil

    # Shell development tools.
    shellcheck
    shfmt

    # General development tools and utilities.
    serve

    # The times be a changin', and so must I.
    github-copilot-cli
    opencode

    # Package managers to support tool installations.
    # rust
    cargo
  ];
}
