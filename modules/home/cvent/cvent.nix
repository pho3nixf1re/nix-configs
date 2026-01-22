_: {
  imports = [
    ../ssh/1password-key.nix
  ];

  home.file.".ssh/ssh_config_cvent".source = ./ssh_config_cvent;

  xdg.configFile = {
    "git/gitconfig-cvent".source = ./gitconfig-cvent;
  };

  programs.git.extraConfig = {
    includeIf."gitdir:~/Workspace/socialtables/".path = "~/.config/git/gitconfig-cvent";
  };

  # Configure SSH public key extraction from 1Password
  ssh.onePasswordKeys.cvent = {
    onePasswordPath = "op://Cvent/Github SSH Key - Cvent/public key";
    outputPath = ".ssh/cvent.pub";
  };
}
