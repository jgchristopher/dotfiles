-- in tools.lua
local M = {}
function M.makeScratch()
	vim.api.nvim_command("enew") -- equivalent to :enew
	vim.bo.buftype = "nofile" -- set the current buffer's (buffer 0) buftype to nofile
	vim.bo.bufhidden = "hide"
	vim.bo.swapfile = false
end

return M
