{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    # Links to `./lua/bootstrap.lua`.
    initLua = ''require("bootstrap")'';
  };

  home.packages = with pkgs; [
    neovide

    # AstroNVim integrates with LazyGit.
    lazygit
  ];

  # Lua modules live at ~/.config/nvim/lua/ alongside Home Manager's init.lua.
  # Any .lua file added under ./lua/ (including subdirectories) is picked up automatically.
  xdg.configFile."nvim/lua" = {
    source = ./lua;
    recursive = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  xdg.configFile."neovide" = {
    source = ./neovide;
    recursive = true;
  }
}
