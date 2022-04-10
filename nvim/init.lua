----------------------------- HELPERS -------------------------------------------
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt
opt.clipboard = "unnamedplus"

require("plugins")
require("user.keymaps")
require("user.lspconfigs")


g.tokyonight_style = "night"
g.tokyonight_italic_functions = true
g.tokyonight_lualine_bold = true

cmd([[colorscheme tokyonight]])
require("lualine").setup({
	options = {
		-- ... your lualine config
		theme = "tokyonight",
	},
})

-------------------------------------- NVIM Tree -----------------------------------------

require("nvim-tree").setup({
	disable_netrw = true,
	hijack_netrw = true,
	open_on_setup = false,
	ignore_ft_on_setup = {},
	auto_close = false,
	open_on_tab = false,
	hijack_cursor = false,
	update_cwd = false,
	update_to_buf_dir = {
		enable = true,
		auto_open = true,
	},
	diagnostics = {
		enable = false,
		icons = {
			hint = "",
			info = "",
			warning = "",
			error = "",
		},
	},
	update_focused_file = {
		enable = false,
		update_cwd = false,
		ignore_list = {},
	},
	system_open = {
		cmd = nil,
		args = {},
	},
	filters = {
		dotfiles = false,
		custom = {},
	},
	view = {
		width = 30,
		height = 30,
		hide_root_folder = false,
		side = "left",
		auto_resize = false,
		mappings = {
			custom_only = false,
			list = {},
		},
	},
})

-- local map = vim.api.nvim_set_keymap

vim.api.nvim_set_keymap("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Leader>e", ":NvimTreeFocus<CR>", { noremap = true })

----------------------------- OPTIONS -------------------------------------------

vim.opt.list = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.autoindent = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

---------------------- TreeSitter ---------------------------------------
local treeSitterConfigs = require("nvim-treesitter.configs")

treeSitterConfigs.setup({
	ensure_installed = "maintained",
	highlight = {
		enable = true,
	},
})

---------------- Telescope ----------------------
vim.api.nvim_set_keymap("n", "<Leader>ff", "<cmd>lua require('telescope.builtin').find_files()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Leader>fb", "<cmd>lua require('telescope.builtin').buffers()<CR>", { noremap = true })


---------- Bufferline -------------------
vim.opt.termguicolors = true
require("bufferline").setup{
    options = {
        offsets = { { filetype = "NvimTree", text = "", padding = 1 } },
        buffer_close_icon = "",
        modified_icon = "",
        close_icon = "",
        show_close_icon = true,
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 14,
        max_prefix_length = 13,
        tab_size = 20,
        show_tab_indicators = true,
        enforce_regular_tabs = false,
        view = "multiwindow",
        show_buffer_close_icons = true,
        separator_style = "thin",
        always_show_bufferline = true,
        diagnostics = false,
    }
}



--------------------------------- Buffer management ----------------------------
function CloseBuffer()
	local opts = {
		next = "cycle", -- how to retrieve the next buffer
		quit = false, -- exit when last buffer is deleted
		--TODO make this a chadrc flag/option
	}

	-- ----------------
	-- Helper functions
	-- ----------------

	-- Switch to buffer 'buf' on each window from list 'windows'
	local function switch_buffer(windows, buf)
		local cur_win = vim.fn.winnr()
		for _, winid in ipairs(windows) do
			winid = tonumber(winid) or 0
			vim.cmd(string.format("%d wincmd w", vim.fn.win_id2win(winid)))
			vim.cmd(string.format("buffer %d", buf))
		end
		vim.cmd(string.format("%d wincmd w", cur_win)) -- return to original window
	end

	-- Select the first buffer with a number greater than given buffer
	local function get_next_buf(buf)
		local next = vim.fn.bufnr("#")
		if opts.next == "alternate" and vim.fn.buflisted(next) == 1 then
			return next
		end
		for i = 0, vim.fn.bufnr("$") - 1 do
			next = (buf + i) % vim.fn.bufnr("$") + 1 -- will loop back to 1
			if vim.fn.buflisted(next) == 1 then
				return next
			end
		end
	end

	-- ----------------
	-- End helper functions
	-- ----------------

	local buf = vim.fn.bufnr()
	if vim.fn.buflisted(buf) == 0 then -- exit if buffer number is invalid
		vim.cmd("close")
		return
	end

	if #vim.fn.getbufinfo({ buflisted = 1 }) < 2 then
		if opts.quit then
			-- exit when there is only one buffer left
			if force then
				vim.cmd("qall!")
			else
				vim.cmd("confirm qall")
			end
			return
		end

		local chad_term, _ = pcall(function()
			return vim.api.nvim_buf_get_var(buf, "term_type")
		end)

		if chad_term then
			-- Must be a window type
			vim.cmd(string.format("setlocal nobl", buf))
			vim.cmd("enew")
			return
		end
		-- don't exit and create a new empty buffer
		vim.cmd("enew")
		vim.cmd("bp")
	end

	local next_buf = get_next_buf(buf)
	local windows = vim.fn.getbufinfo(buf)[1].windows

	-- force deletion of terminal buffers to avoid the prompt
	if force or vim.fn.getbufvar(buf, "&buftype") == "terminal" then
		local chad_term, type = pcall(function()
			return vim.api.nvim_buf_get_var(buf, "term_type")
		end)

		-- TODO this scope is error prone, make resilient
		if chad_term then
			if type == "wind" then
				-- hide from bufferline
				vim.cmd(string.format("%d bufdo setlocal nobl", buf))
				-- switch to another buff
				-- TODO switch to next buffer, this works too
				vim.cmd("BufferLineCycleNext")
			else
				local cur_win = vim.fn.winnr()
				-- we can close this window
				vim.cmd(string.format("%d wincmd c", cur_win))
				return
			end
		else
			switch_buffer(windows, next_buf)
			vim.cmd(string.format("bd! %d", buf))
		end
	else
		switch_buffer(windows, next_buf)
		vim.cmd(string.format("silent! confirm bd %d", buf))
	end
	-- revert buffer switches if user has canceled deletion
	if vim.fn.buflisted(buf) == 1 then
		switch_buffer(windows, buf)
	end
end

vim.api.nvim_set_keymap("n", "<Leader>x", "<cmd>lua CloseBuffer()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Leader>q", ":qa!<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-s>", ":w!<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-S>", ":wa!<CR>", { noremap = true })

