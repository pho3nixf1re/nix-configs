{
  imports = [
    ../modules/home/base.nix
    ../modules/home/dev.nix
    ../modules/home/gaming-tools.nix
    ../modules/home/ssh/ssh.nix
    ../modules/home/zsh/zsh.nix
    ../modules/home/plasma/plasma.nix
  ];

  home.username = "pho3nixf1re";
  home.homeDirectory = "/home/pho3nixf1re";
  home.stateVersion = "26.05";

  programs.firefox.enable = true;
}
