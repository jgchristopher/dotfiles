local status, tokio = pcall(require, 'tokyonight')
if (not status) then return end

tokio.setup {
  style = 'night',
}

vim.cmd [[colorscheme tokyonight-night]]
