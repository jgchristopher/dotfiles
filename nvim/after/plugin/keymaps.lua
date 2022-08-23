-- Shorten function name
local set = vim.keymap.set
vim.g.mapleader = " "

-- Navigate buffers
set("n", "<S-l>", ":bnext<CR>")
set("n", "<S-h>", ":bprevious<CR>")
set("n", "<C-n>", ":NvimTreeToggle<CR>")
set("n", "<Leader>e", ":NvimTreeFocus<CR>")
set("n", "<leader>ff", function() require('telescope.builtin').find_files() end)
set("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
set("n", "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>")
--set("n", "<Leader>x", "<cmd>lua CloseBuffer()<CR>")
set("n", "<Leader>q", ":qa!<CR>")
set("n", "<C-s>", ":w!<CR>")
set("n", "<C-S>", ":wa!<CR>")
set("i", "<C-h>", "<Left>")
set("i", "<C-e>", "<End>")
set("i", "<C-l>", "<Right>")
set("i", "<C-j>", "<Down>")
set("i", "<C-k>", "<Up>")
set("i", "<C-a>", "<ESC>^i")

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
--
--
local dap = require('dap')
local widgets = require('dap.ui.widgets')
local dapui = require('dapui')
local debug = require('user/debug')

vim.keymap.set("n", "<leader>b", function() dap.toggle_breakpoint() end)
vim.keymap.set("n", "<leader>B", function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end)
vim.keymap.set("n", "<leader>1", function() dap.continue() end)
vim.keymap.set("n", "<leader>2", function() dap.step_into() end)
vim.keymap.set("n", "<leader>3", function() dap.step_over() end)
vim.keymap.set("n", "<leader>4", function() dap.step_out() end)
vim.keymap.set('n', '<leader>dgn', function() dap.run_to_cursor() end)
vim.keymap.set('n', '<leader>dgc', function() dap.terminate() end)
vim.keymap.set('n', '<leader>dgR', function() dap.clear_breakpoints() end)
vim.keymap.set('n', '<leader>dge', function() dap.set_exception_breakpoints({ "all" }) end)
vim.keymap.set('n', '<leader>dga', function() debug.dbgPhoenix() end)
vim.keymap.set('n', '<leader>dgA', function() debug.dbgTests() end)
vim.keymap.set('n', '<leader>dgi', function() widgets.hover() end)
vim.keymap.set('n', '<leader>dg?', function() widgets.centered_float(widgets.scopes) end)
vim.keymap.set('n', '<leader>dgk', function() dap.up() end)
vim.keymap.set('n', '<leader>dgj', function() dap.down() end)
vim.keymap.set('n', '<leader>dgr', function() dap.repl.toggle({}, "vsplit") end)
vim.keymap.set('n', '<leader>dgu', function() dapui.open() end)
vim.keymap.set('n', '<leader>dgU', function() dapui.close() end)
