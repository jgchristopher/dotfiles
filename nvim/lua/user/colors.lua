local M = {}
-- if theme given, load given theme if given, otherwise nvchad_theme
M.init = function(theme)
	local present, base16 = pcall(require, "base16")

	if present then
		-- first load the base16 theme
		local ok, array = pcall(base16.themes, theme)

		if ok then
			base16(array, true)
			-- unload to force reload
			package.loaded["user.highlights" or false] = nil
			-- then load the highlights
			require("user.highlights")
		else
			pcall(vim.cmd, "colo " .. theme)
		end
	else
		pcall(vim.cmd, "colo " .. theme)
	end
end

return M
