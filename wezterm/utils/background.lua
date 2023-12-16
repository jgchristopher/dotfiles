local M = {}
local h = require("utils.helpers")

local get_colors = function()
	if h.is_dark() then
		return {
			"hsla(265, 52%, 3%, 1)",
			"hsla(265, 52%, 6%, 1)",
			"hsla(265, 52%, 3%, 1)",
		}
	else
		return {
			"hsla(278, 52%, 82%, 1)",
			"hsla(278, 52%, 85%, 1)",
			"hsla(278, 52%, 82%, 1)",
		}
	end
end

M.get_background = function()
	return {
		source = {
			Gradient = {
				orientation = "Horizontal",
				colors = get_colors(),
				interpolation = "CatmullRom",
				blend = "Rgb",
				noise = 0,
			},
		},
		width = "100%",
		height = "100%",
		opacity = h.is_dark() and 0.95 or 0.7,
	}
end

return M
