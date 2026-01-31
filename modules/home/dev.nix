{ lib, pkgs, ... }:

{
  programs.vscode.enable = true;

  home.packages = with pkgs; [
    # Development runtimes.
    nodejs
    python3

    # Nix development tools.
    nixfmt
    nil

    # General development tools and utilities.
    git
    gh
  ];
}
