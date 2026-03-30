return {
	"zbirenbaum/copilot.lua",
	dependencies = { "copilotlsp-nvim/copilot-lsp" },
	config = function()
		require("copilot").setup({
			nes = {
				enabled = true,
				auto_trigger = true,
			},
		})
	end,
}
