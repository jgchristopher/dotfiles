-- Shorten function name
local set = vim.keymap.set
vim.g.mapleader = " "


-- Don't yank with x
--set("n", 'x', '"_x')

-- Navigate buffers
set("n", "<Leader>q", ":qa!<CR>")
set("n", "<C-s>", ":w!<CR>")
set("n", "<C-S>", ":wa!<CR>")
set("i", "<C-h>", "<Left>")
set("i", "<C-e>", "<End>")
set("i", "<C-l>", "<Right>")
set("i", "<C-j>", "<Down>")
set("i", "<C-k>", "<Up>")
set("i", "<C-a>", "<ESC>^i")

set("n", "<C-d>", "<C-d>zz")
set("n", "<C-u>", "<C-u>zz")


set("v", "J", ":m '>+1<CR>gv=gv")
set("v", "K", ":m '<-2<CR>gv=gv")
