local wezterm = require("wezterm")
local M = {}

M.get_random_entry = function(tbl)
	local keys = {}
	for key, _ in ipairs(tbl) do
		table.insert(keys, key)
	end
	local randomKey = keys[math.random(1, #keys)]
	return tbl[randomKey]
end

M.is_dark = function()
	return wezterm.gui.get_appearance():find("Dark")
end

return M
