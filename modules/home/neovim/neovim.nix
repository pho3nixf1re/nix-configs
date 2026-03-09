{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    extraLuaConfig = ''
      -- ---------------------------------------------------------------------------
      -- AstroNvim bootstrap via lazy.nvim
      -- ---------------------------------------------------------------------------
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({
          "git", "clone", "--filter=blob:none", "--branch=stable",
          lazyrepo, lazypath,
        })
        if vim.v.shell_error ~= 0 then
          vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to continue..." },
          }, true, {})
          vim.fn.getchar()
          os.exit(1)
        end
      end
      vim.opt.rtp:prepend(lazypath)
      require("lazy_setup")

      -- ---------------------------------------------------------------------------
      -- Neovide GUI settings
      -- ---------------------------------------------------------------------------
      if vim.g.neovide then
        -- Mirror the OS light/dark preference into vim.o.background automatically.
        -- "auto" reads the system appearance and updates background on change.
        vim.g.neovide_theme = "auto"

        vim.o.guifont = "FiraCode Nerd Font:h13"
        vim.g.neovide_cursor_animation_length = 0.1
        vim.g.neovide_scroll_animation_length = 0.3
        vim.g.neovide_padding_top    = 4
        vim.g.neovide_padding_bottom = 4
        vim.g.neovide_padding_left   = 4
        vim.g.neovide_padding_right  = 4
      end
    '';
  };

  home.packages = with pkgs; [
    neovide
  ];

  # Lua modules live at ~/.config/nvim/lua/ alongside Home Manager's init.lua.
  xdg.configFile = {
    "nvim/lua/lazy_setup.lua".source = ./lua/lazy_setup.lua;
    "nvim/lua/community.lua".source = ./lua/community.lua;
    "nvim/lua/plugins/astroui.lua".source = ./lua/plugins/astroui.lua;
    "nvim/lua/plugins/astrocore.lua".source = ./lua/plugins/astrocore.lua;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
