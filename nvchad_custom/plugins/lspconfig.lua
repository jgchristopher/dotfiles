local M = {}

M.setup_lsp = function(attach, capabilities)
   local lspconfig = require "lspconfig"
    
   local path_to_elixirls = vim.fn.expand("~/.local/share/nvim/lsp_servers/elixir/elixir-ls/language_server.sh")
  
   lspconfig.elixirls.setup {
      on_attach = attach,
      capabilities = capabilities,
      cmd = {path_to_elixirls},
   }
end

return M
