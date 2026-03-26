-- AstroCommunity plugin specs.
-- See https://github.com/AstroNvim/astrocommunity for available packs.
return {
	-- Pull in the community repository so its specs can be imported below.
	"AstroNvim/astrocommunity",

	-- Solarized Osaka colorscheme (supports light + dark via vim.o.background).
	{ import = "astrocommunity.colorscheme.solarized-osaka-nvim" },

	-- Disable the transparency that the community pack enables by default.
	-- In terminal Neovim, transparent Normal looks fine because the terminal
	-- background shows through. In Neovide there is no terminal background, so
	-- guibg=NONE renders as solid black.
	{
		"craftzdog/solarized-osaka.nvim",
		opts = {
			transparent = false,
		},
	},
}
