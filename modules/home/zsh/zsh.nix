{ lib, pkgs, ... }:

let
  inherit (pkgs.stdenv) isDarwin;
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

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

    initContent = ''
      # Load OS detection variables
      source ${./os-detection.zsh}

      # Load additional configuration from conf.d
      for zshSource in ~/.config/zsh/conf.d/*.zsh; do
        source "$zshSource"
      done
    '';
  };

  # Copy all conf.d files to be sourced by zsh.
  xdg.configFile = builtins.listToAttrs (
    builtins.map (filename: {
      name = "zsh/conf.d/${filename}";
      value = {
        source = ./conf.d/${filename};
      };
    }) (builtins.attrNames (builtins.readDir ./conf.d))
  );
}
