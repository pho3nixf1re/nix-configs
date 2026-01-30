{ ... }:

{
  imports = [
    ../modules/home/ssh/ssh.nix
    ../modules/home/git/git.nix
    ../modules/home/cvent/cvent.nix
  ];

  home.username = "mturney";
  home.homeDirectory = "/Users/mturney";
  home.stateVersion = "26.05";
}
