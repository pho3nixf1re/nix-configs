{ pkgs, ... }:

{
  programs.vscode.enable = true;

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
  ];
}
