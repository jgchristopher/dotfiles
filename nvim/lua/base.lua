local opt = vim.opt

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

opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

-- experimental
opt.backspace = "start,eol,indent"

opt.cmdheight = 0

-- Globals
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
