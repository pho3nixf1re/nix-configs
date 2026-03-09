-- AstroUI configuration – sets the default colorscheme and wires up
-- automatic dark/light switching when vim.o.background changes (driven by
-- Neovide's neovide_theme = "auto" which mirrors the OS appearance).
return {
  "AstroNvim/astroui",
  opts = {
    colorscheme = "solarized-osaka",
  },
  config = function(_, opts)
    require("astroui").setup(opts)

    -- Re-apply the colorscheme whenever Neovide notifies Neovim of an OS
    -- light/dark change (sets vim.o.background = "light"|"dark").
    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "background",
      desc = "Reload solarized-osaka on system appearance change",
      callback = function()
        vim.schedule(function()
          vim.cmd.colorscheme("solarized-osaka")
        end)
      end,
    })
  end,
}
