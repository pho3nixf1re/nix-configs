{ pkgs, ... }:

{
  imports = [
    ../modules/home/base.nix
    ../modules/home/dev.nix
    ../modules/home/gaming-tools.nix
    ../modules/home/ssh/ssh.nix
  ];

  home.username = "pho3nixf1re";
  home.homeDirectory = "/home/pho3nixf1re";
  home.stateVersion = "24.05";

  programs.firefox.enable = true;
}
