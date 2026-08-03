{ pkgs, lib, ... }:

{
  # Self-heal: on some fresh installs (observed on multiple macOS systems), the
  # lazy.nvim plugin cache and lockfile have ended up owned by root instead of
  # the user — likely from an early root-context nvim/activation invocation —
  # which breaks git's ownership checks that lazy.nvim relies on to
  # check/update plugins, silently freezing every plugin at whatever commit
  # was checked out at the time. bootstrap.lua now refuses to run as root to
  # stop this at the source; this reclaims ownership if it ever happens again.
  home.activation.fixNvimPluginOwnership = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for path in "$HOME/.local/share/nvim" "$HOME/.config/nvim/lazy-lock.json"; do
      if [ -e "$path" ]; then
        owner="$(/usr/bin/stat -f %Su "$path" 2>/dev/null || stat -c %U "$path" 2>/dev/null)"
        if [ -n "$owner" ] && [ "$owner" != "$(id -un)" ]; then
          chown -R "$(id -un)" "$path" 2>/dev/null || true
        fi
      fi
    done
  '';

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
  };
}
