{
  config,
  sopsAgeKeyFile ? "${config.xdg.configHome}/sops/age/keys.txt",
  ...
}:

{
  imports = [
    ../modules/home/base.nix
    ../modules/home/zsh/zsh.nix
    ../modules/home/wezterm/wezterm.nix
    ../modules/home/starship/starship.nix
    ../modules/home/ssh/ssh.nix
    ../modules/home/git/git.nix
    ../modules/home/neovim/neovim.nix
    ../modules/home/dev.nix
    ../modules/home/containers/containers.nix
    ../modules/home/1password/1password.nix
    ../modules/home/lazygit/lazygit.nix
    ../modules/home/mise/mise.nix
  ];

  programs.firefox.enable = true;

  programs.claude-code = {
    enable = true;
  };

  sops = {
    defaultSopsFile = ../secrets/smb.yaml;
    age.keyFile = sopsAgeKeyFile;
  };

  home.username = "pho3nixf1re";
  home.homeDirectory = "/Users/pho3nixf1re";
  home.stateVersion = "26.05";
}
