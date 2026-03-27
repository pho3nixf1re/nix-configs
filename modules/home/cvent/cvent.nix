{
  pkgs,
  config,
  lib,
  ...
}:

{
  # Gitconfig for Cvent work points ssh command to this file.
  home.file.".ssh/ssh_config_cvent".source = ./ssh_config_cvent;
  home.file.".ssh/cvent.pub".source = ./cvent.pub;

  xdg.configFile = {
    "git/cvent.gitconfig".source = ./cvent.gitconfig;
  };

  programs.git.settings = {
    includeIf."gitdir:~/Workspace/socialtables/".path = "~/.config/git/cvent.gitconfig";
  };

  home.packages = with pkgs; [
    circleci-cli

    # Local development environment dependencies.
    poppler
    vips
  ];

  # Add iterm-automation alias that executes the iterm2 services launcher
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    st-run = "nix develop --impure \"$NIX_FLAKE_PATH#iterm-automation\" --command python ~/Workspace/socialtables/repo-runner/launchers/iterm2/services.py";
  };

  # Global oxfmt config – matches SocialTables' Prettier style.
  # Only options that differ from oxfmt's own defaults are listed.
  home.file.".oxfmtrc.json".text = builtins.toJSON {
    "$schema" =
      "https://raw.githubusercontent.com/oxc-project/oxc/main/npm/oxfmt/configuration_schema.json";
    bracketSpacing = false;
    printWidth = 80;
    singleQuote = true;
    trailingComma = "es5";
  };
}
