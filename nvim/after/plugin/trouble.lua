local status, trbl = pcall(require, 'trouble')
if (not status) then return end

trbl.setup {
  width = 50,
  mode = 'document_diagnostics',
}

vim.keymap.set("n", "<leader>tt", "<cmd>TroubleToggle<cr>",
  {silent = true, noremap = true}
)
