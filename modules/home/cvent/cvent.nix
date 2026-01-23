_: {
  imports = [
    ../ssh/1password-key.nix
  ];

  home.file.".ssh/ssh_config_cvent".source = ./ssh_config_cvent;

  xdg.configFile = {
    "git/cvent.gitconfig".source = ./cvent.gitconfig;
  };

  programs.git.extraConfig = {
    includeIf."gitdir:~/Workspace/socialtables/".path = "~/.config/git/cvent.gitconfig";
  };

  ssh.onePasswordKeys.cvent = {
    onePasswordPath = "op://Cvent/Github SSH Key - Cvent/public key";
    outputPath = ".ssh/cvent.pub";
  };
}
