{ pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    # Links to ./wezterm.lua
    extraConfig = ''return require("config/wezterm")'';
  };

  # $XDG_CONFIG_HOME/wezterm/wezterm.lua
  xdg.configFile."wezterm/config" = {
    source = ./config;
    recursive = true;
  };
}
