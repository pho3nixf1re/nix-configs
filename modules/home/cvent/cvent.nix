_: {
  # Gitconfig for Cvent work points ssh command to this file.
  home.file.".ssh/ssh_config_cvent".source = ./ssh_config_cvent;
  home.file.".ssh/cvent.pub".source = ./cvent.pub;

  xdg.configFile = {
    "git/cvent.gitconfig".source = ./cvent.gitconfig;
  };

  programs.git.settings = {
    includeIf."gitdir:~/Workspace/socialtables/".path = "~/.config/git/cvent.gitconfig";
  };
}
