local cmd = vim.cmd
local g = vim.g
local opt = vim.opt

opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.mouse = "a"

require("plugins")
require("user.keymaps")
require("user.lspconfigs")
require("user.bufferline")
require("user.telescope")

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

--------------------------------- Buffer management ----------------------------
function CloseBuffer()
	local opts = {
		next = "cycle", -- how to retrieve the next buffer
		quit = false, -- exit when last buffer is deleted
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
		-- don't exit and create a new empty buffer
		vim.cmd("enew")
		vim.cmd("bp")
	end

	local next_buf = get_next_buf(buf)
	local windows = vim.fn.getbufinfo(buf)[1].windows

	-- force deletion of terminal buffers to avoid the prompt
	if vim.fn.getbufvar(buf, "&buftype") == "terminal" then
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

vim.api.nvim_set_keymap("i", "<C-h>", "<Left>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-e>", "<End>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-l>", "<Right>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-j>", "<Down>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-k>", "<Up>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-a>", "<ESC>^i", { noremap = true })
