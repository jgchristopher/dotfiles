local status, ibl = pcall(require, 'indent_blankline')
if (not status) then return end

local status_tokio, tokyonight_colors = pcall(require, 'tokyonight.colors')
if (status_tokio) then

  local tyc = tokyonight_colors.setup { style = 'night' }
  local util = require("tokyonight.util")
  vim.api.nvim_set_hl(0, 'IndentBlanklineIndent1', { fg = util.lighten(tyc.red, 0.4) })
  vim.api.nvim_set_hl(0, 'IndentBlanklineIndent2', { fg = util.lighten(tyc.yellow, 0.4) })
  vim.api.nvim_set_hl(0, 'IndentBlanklineIndent3', { fg = util.lighten(tyc.green, 0.4) })
  vim.api.nvim_set_hl(0, 'IndentBlanklineIndent4', { fg = util.lighten(tyc.cyan, 0.4) })
  vim.api.nvim_set_hl(0, 'IndentBlanklineIndent5', { fg = util.lighten(tyc.blue, 0.4) })
  vim.api.nvim_set_hl(0, 'IndentBlanklineIndent6', { fg = util.lighten(tyc.purple, 0.4) })

else
  vim.cmd [[highlight IndentBlanklineIndent1 guifg=#E06C75 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent2 guifg=#E5C07B gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent3 guifg=#98C379 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent4 guifg=#56B6C2 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent5 guifg=#61AFEF gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineIndent6 guifg=#C678DD gui=nocombine]]
end

ibl.setup {
  show_end_of_line = false,
  space_char_blankline = " ",
  char_highlight_list = {
    "IndentBlanklineIndent1",
    "IndentBlanklineIndent2",
    "IndentBlanklineIndent3",
    "IndentBlanklineIndent4",
    "IndentBlanklineIndent5",
    "IndentBlanklineIndent6",
  },
}

vim.opt.list = true
--vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"
