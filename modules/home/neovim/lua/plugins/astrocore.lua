-- AstroCore configuration – editor options, key mappings, and autocommands.
-- See https://docs.astronvim.com/configuration/customizing_plugins
return {
	"AstroNvim/astrocore",
	opts = {
		options = {
			opt = {
				colorcolumn = "80",
				relativenumber = true,
				number = true,
				-- Using `codebook` LSP for spelling.
				spell = false,
				signcolumn = "yes",
				wrap = false,
			},
		},
		-- Add or override key mappings here, e.g.:
		-- mappings = {
		--   n = {
		--     ["<Leader>w"] = { "<cmd>w<cr>", desc = "Save file" },
		--   },
		-- },
	},
}
