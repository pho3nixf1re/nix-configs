{ pkgs, ... }:

{
  # SteamOS uses fixed 'deck' username.
  home.username = "deck";
  home.homeDirectory = "/home/deck";
  home.stateVersion = "26.05";

  # SteamOS runs KDE Plasma under X11.
  custom.display.server = "x11";

  # Allows apps to appear in menu.
  targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    home-manager
    _1password-gui
    _1password-cli
  ];
}
