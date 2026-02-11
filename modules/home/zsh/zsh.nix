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

      nix-dev = "nix develop \"$NIX_FLAKE_PATH#\"";
      nix-flake = "nix flake --flake \"$NIX_FLAKE_PATH\"";
      nix-update = "nix flake update --flake \"$NIX_FLAKE_PATH\"";
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

    # Load custom zsh configuration, os-detection first, then conf.d files
    plugins = [
      {
        name = "os-detection";
        src = ./.;
        file = "os-detection.zsh";
      }
    ]
    # Load all zsh files in conf.d here.
    ++ builtins.map (filename: {
      name = lib.removeSuffix ".zsh" filename;
      src = ./conf.d;
      file = filename;
    }) (builtins.attrNames (builtins.readDir ./conf.d));

    # Source local-only customizations from conf.d directory.
    initContent = /* zsh */ ''
      for zshSource in ${config.xdg.configHome}/zsh/conf.d/*.zsh(N); do
        source "$zshSource"
      done
    '';
  };
}
