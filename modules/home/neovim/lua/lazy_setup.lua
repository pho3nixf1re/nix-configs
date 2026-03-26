-- Configure and initialise lazy.nvim with AstroNvim core + user plugins.
-- This file is sourced by the bootstrapped lazy.nvim in init.lua.
require("lazy").setup({
	-- AstroNvim core
	{
		"AstroNvim/AstroNvim",
		version = "^5",
		import = "astronvim.plugins",
	},
	-- AstroCommunity plugin specs (colorscheme, language packs, etc.)
	{ import = "community" },
	-- User plugin overrides
	{ import = "plugins" },
}, {
	install = {
		-- Try solarized-osaka first, fall back to a built-in colorscheme during
		-- the very first install run so nothing looks broken.
		colorscheme = { "solarized-osaka", "habamax" },
	},
	ui = { backdrop = 100 },
})
