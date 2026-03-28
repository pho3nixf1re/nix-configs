-- Neovide GUI settings via AstroCore.
-- See https://docs.astronvim.com/recipes/neovide
if not vim.g.neovide then
	return {}
end

return {
	"AstroNvim/astrocore",
	---@type AstroCoreOpts
	opts = {
		options = {
			opt = {
				guifont = "FiraCode Nerd Font:h18",
			},
			g = {
				-- Mirror the OS light/dark preference into vim.o.background
				-- automatically. "auto" reads the system appearance and
				-- updates background on change.
				neovide_theme = "auto",
				neovide_cursor_animation_length = 0.1,
				neovide_scroll_animation_length = 0.3,
				neovide_padding_top = 4,
				neovide_padding_bottom = 4,
				neovide_padding_left = 4,
				neovide_padding_right = 4,
			},
		},
	},
}
