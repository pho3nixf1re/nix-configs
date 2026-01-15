{ pkgs, ... }:

{
  # SteamOS-specific Home Manager overrides only. No system-level assumptions.

  # SteamOS uses fixed 'deck' username.
  home.username = "deck";
  home.homeDirectory = "/home/deck";

  home.sessionVariables = {
    EDITOR = "code";
  };
}
