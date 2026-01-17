{ pkgs, ... }:
{
  xdg.configFile = {
    "zsh/conf.d/git.zsh".source = ./git.zsh;
    "git/gitconfig".source = ./gitconfig;
    "git/config".source = if pkgs.stdenv.isLinux then ./gitconfig-linux else ./gitconfig-darwin;
  };

  home.file = {
    ".gitignore".source = ./gitignore;
  };
}
