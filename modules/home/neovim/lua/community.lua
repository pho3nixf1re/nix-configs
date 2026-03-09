-- AstroCommunity plugin specs.
-- See https://github.com/AstroNvim/astrocommunity for available packs.
return {
  -- Pull in the community repository so its specs can be imported below.
  "AstroNvim/astrocommunity",

  -- Solarized Osaka colorscheme (supports light + dark via vim.o.background).
  { import = "astrocommunity.colorscheme.solarized-osaka-nvim" },
}
