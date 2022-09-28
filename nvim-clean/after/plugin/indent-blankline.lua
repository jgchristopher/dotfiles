local status, ibl = pcall(require, 'indent_blankline')
if (not status) then return end

ibl.setup {
  show_end_of_line = true
}

vim.opt.list = true
vim.opt.listchars:append "eol:↴"
