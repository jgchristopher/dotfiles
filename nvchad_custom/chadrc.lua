
local M = {}
-- NvChad included plugin options & overrides
M.plugins = {
   options = {
      lspconfig = {
          setup_lspconf = "custom.plugins.lspconfig",
      },
   },
}

return M
