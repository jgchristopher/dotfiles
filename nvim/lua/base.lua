local opt = vim.opt
local g = vim.g

opt.title = true
opt.cmdheight = 1
opt.showcmd = true
opt.backup = false
opt.wrap = true
opt.clipboard = "unnamedplus"

opt.mouse = "a"
opt.ignorecase = true
opt.smartcase = true

opt.list = true
opt.number = true
opt.relativenumber = true
opt.autoindent = true

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.splitbelow = true
opt.splitright = true

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 10

-- experimental
opt.backspace = 'start,eol,indent'

-- Globals
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
