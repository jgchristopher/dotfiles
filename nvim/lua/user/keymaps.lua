local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap
vim.g.mapleader = " "

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

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true })
keymap("n", "<Leader>e", ":NvimTreeFocus<CR>", { noremap = true })
keymap("n", "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>", { noremap = true })
keymap("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", { noremap = true })
keymap("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", { noremap = true })
keymap("n", "<Leader>x", "<cmd>lua CloseBuffer()<CR>", { noremap = true })
keymap("n", "<Leader>q", ":qa!<CR>", { noremap = true })
keymap("n", "<C-s>", ":w!<CR>", { noremap = true })
keymap("n", "<C-S>", ":wa!<CR>", { noremap = true })

keymap("i", "<C-h>", "<Left>", { noremap = true })
keymap("i", "<C-e>", "<End>", { noremap = true })
keymap("i", "<C-l>", "<Right>", { noremap = true })
keymap("i", "<C-j>", "<Down>", { noremap = true })
keymap("i", "<C-k>", "<Up>", { noremap = true })
keymap("i", "<C-a>", "<ESC>^i", { noremap = true })

-- telescope-repo
vim.keymap.set("n", "<leader>rl", ":lua require'user.telescope'.repo_list()")
vim.keymap.set(
	"n",
	"<leader>k",
	":lua require'telescope'.extensions.command_palette.command_palette()"
)
vim.keymap.set(
	"n",
	"<leader>n",
	":lua require'telescope'.extensions.neoclip.default()"
)

-- Debugging
vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
