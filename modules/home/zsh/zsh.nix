{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (pkgs.stdenv) isDarwin;
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    sessionVariables = {
      NIX_FLAKE_PATH = "$HOME/nix-configs";
    };

    shellAliases = {
      less = "less -R";
      nr = "npm run";
      ni = "npm install";
    };

    oh-my-zsh = {
      enable = true;
      # Disable oh-my-zsh theme, using starship instead.
      # theme = "";
      plugins = [
        "brew"
        "asdf"
        "vi-mode"
        "tmux"
        "autojump"
        "encode64"
        "extract"
        "urltools"
        "git"
        "git-extras"
        "gitignore"
        "git-escape-magic"
        "docker"
        "docker-compose"
        "node"
        "npm"
        "yarn"
        "python"
        "pip"
      ]
      ++ lib.optionals isDarwin [ "macos" ];
    };

    # Load os-detection first so conf.d files can use its helpers.
    plugins = [
      {
        name = "os-detection";
        src = ./.;
        file = "os-detection.zsh";
      }
    ];

    # Source all conf.d files; new files are picked up automatically.
    initContent = /* zsh */ ''
      for zshSource in ${config.xdg.configHome}/zsh/conf.d/*.zsh(N); do
        source "$zshSource"
      done
    '';
  };

  # Link the entire conf.d directory; any .zsh file added there is sourced automatically.
  xdg.configFile."zsh/conf.d" = {
    source = ./conf.d;
    recursive = true;
  };

  # Automatically load zsh environment to nix shells.
  programs.nix-your-shell = {
    enable = true;
    enableZshIntegration = true;
  };
}
