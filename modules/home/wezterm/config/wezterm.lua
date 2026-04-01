local wezterm = require("wezterm")

function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Solarized Dark (Gogh)"
	else
		return "Solarized Light (Gogh)"
	end
end

return {
	font = wezterm.font("FiraCode Nerd Font"),
	font_size = 18.0,
	color_scheme = scheme_for_appearance(get_appearance()),
	hide_tab_bar_if_only_one_tab = true,
	window_background_opacity = 0.9,
}
