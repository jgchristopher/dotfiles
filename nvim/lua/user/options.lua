local g = vim.g
local opt = vim.opt

opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.mouse = "a"
opt.ignorecase = true
opt.smartcase = true

opt.list = true
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.autoindent = true

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- g.glow_style = "/Users/johnchristopher/gitprojects/dotfiles/glow/dracula.json"
g.glow_border = "rounded"

g.tokyonight_style = "night"
g.tokyonight_italic_functions = true
g.tokyonight_lualine_bold = true

-- g.catppuccin_flavour = "mocha"
-- g.catppuccin_flavour = "frappe"
g.catppuccin_flavour = "macchiato"
-- g.catppuccin_flavour = "latte"
--
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 10
