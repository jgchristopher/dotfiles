local map = require("core.utils").map

map("n", "<leader>gf", ":Telescope git_files <CR>")
map("n", "<leader>q", ":qa! <CR>")
map("", "gr", "<cmd>lua require'telescope.builtin'.lsp_references{}<CR>")
map("n", "<leader>fs", "<cmd>lua vim.lsp.buf.formatting_sync()<CR>")
