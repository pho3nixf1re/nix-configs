{
  pkgs,
  pkgsLatest,
  lib,
  ...
}:

{
  programs.vscode.enable = true;

  home.packages = with pkgsLatest; [
    # Development runtimes.
    nodejs
    python3
    python3.pkgs.pip
    uv

    # Nix development tools.
    nixfmt
    nil

    # Shell development tools.
    shellcheck
    shfmt

    # JavaScript/TypeScript tooling.
    oxfmt
    oxlint

    # General development tools and utilities.
    serve

    # The times be a changin', and so must I.
    github-copilot-cli

    # Package managers to support tool installations.
    # rust
    cargo
  ]
  # On macOS opencode is installed via Homebrew (see modules/darwin/macos-apps.nix).
  ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgsLatest.opencode ];
}
