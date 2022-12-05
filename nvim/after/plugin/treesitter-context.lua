local status, tsc = pcall(require, 'treesitter-context')
if (not status) then return end

tsc.setup({})
