{ pkgs, ... }:

{
  # SteamOS uses fixed 'deck' username.
  home.username = "deck";
  home.homeDirectory = "/home/deck";
  home.stateVersion = "26.05";

  # Allows apps to appear in menu.
  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    _1password-gui
    _1password-cli
  ];
}
