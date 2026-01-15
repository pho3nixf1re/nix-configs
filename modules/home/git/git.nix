{ pkgs, ... }:
{
  home.file = {
    ".config/zsh/git.zsh".source = ./git.zsh;
    ".config/git/gitconfig".source = ./gitconfig;
    ".config/git/config".source = if pkgs.stdenv.isLinux then ./gitconfig-linux else ./gitconfig-darwin;
    ".gitignore".source = ./gitignore;
  };
}
