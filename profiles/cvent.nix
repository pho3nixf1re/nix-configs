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
    ../modules/home/aws-dev.nix
    ../modules/home/containers/containers.nix
    ../modules/home/1password/1password.nix
    ../modules/home/cvent/cvent.nix
    ../modules/home/mise/mise.nix
    ../modules/home/canvas-compilation-libraries/default.nix
  ];

  home.username = "mturney";
  home.homeDirectory = "/Users/mturney";
  home.stateVersion = "26.05";
}
