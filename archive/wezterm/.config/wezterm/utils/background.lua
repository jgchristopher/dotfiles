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
			"#ffffff",
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
		-- opacity = h.is_dark() and 0.95 or 0.95,
		opacity = 0.95,
	}
end

return M
