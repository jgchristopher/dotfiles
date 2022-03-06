require("custom.mappings")

vim.opt.foldexpr = "" -- set to "nvim_treesitter#foldexpr()" for treesitter based folding
vim.opt.foldmethod = "indent" -- folding set to "expr" for treesitter based folding
vim.opt.foldlevel = 99 -- I don't want folding to be default closed
