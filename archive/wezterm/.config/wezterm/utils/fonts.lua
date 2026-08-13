local wezterm = require("wezterm")

local h = require("utils.helpers")
local M = {}

M.get_font = function()
	local fonts = {
		"Monaspace Neon",
	}
	local family = h.get_random_entry(fonts)
	return wezterm.font_with_fallback({
		{ family = family, weight = "Bold" },
		{ family = "MonoLisa", weight = "Medium" },
	})
end

return M
