local status, saga = pcall(require, 'lspsaga')
if (not status) then return end

saga.setup {
  server_filetype_map = {
  }
}

local opts = { noremap = true, silent = true }
-- -- map("n", "df", "<cmd>lua vim.lsp.buf.formatting_seq_sync()<cr>", map_opts)
-- map("n", "gd", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", map_opts)
-- map("n", "dt", "<cmd>lua vim.lsp.buf.definition()<cr>", map_opts)
-- map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", map_opts)
-- map("n", "gD", "<cmd>lua vim.lsp.buf.implementation()<cr>", map_opts)
-- map("n", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", map_opts)
-- map("n", "1gD", "<cmd>lua vim.lsp.buf.type_definition()<cr>", map_opts)
-- map("n", "<space>r", "<cmd>vim.lsp.codelens.run()<cr>", map_opts)

-- vim.keymap.set("n", "<C-j>", "<cmd>Lspsaga diagnostic_jump_next<cr>", opts)
vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
-- vim.keymap.set("n", "gd", "<cmd>Lspsaga lsp_finder<cr>", opts)
-- vim.keymap.set("i", "<C-k>", "<cmd>Lspsaga signature_help<cr>", opts)
-- vim.keymap.set("n", "gp", "<cmd>Lspsaga preview_definition<cr>", opts)
-- vim.keymap.set("n", "gr", "<cmd>Lspsaga rename<cr>", opts)
