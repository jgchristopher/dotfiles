local mason_status, mason = pcall(require, 'mason')
local ms_config_status, mason_config = pcall(require, 'mason-lspconfig')
local status, nvim_lsp = pcall(require, 'lspconfig')
local status2, wk = pcall(require, 'which-key')

if (not status) then return end
if (not status2) then print('Missing which-key plugin') return end
if (not mason_status) then return end
if (not ms_config_status) then return end

local protocol = require('vim.lsp.protocol')

local on_attach = function(client, _)
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_command [[augroup Format]]
    vim.api.nvim_command [[autocmd! * <buffer>]]
    vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()]]
    vim.api.nvim_command [[augroup END]]
  end

  -- local function map(...)
  --   vim.api.nvim_buf_set_keymap(bufnr, ...) -- --     vim.api.nvim_buf_set_keymap(bufnr, ...)
  -- end
  --
  -- local map_opts = { noremap = true, silent = true } -- --   local map_opts = { noremap = true, silent = true }

  wk.register({
    l = {
      name = "lsp",
      f = { "<cmd>lua vim.lsp.buf.format()<cr>", "Format Code" },
      i = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Go to implementation" },
      r = { "<cmd>vim.lsp.codelens.run()<cr>", "Run Code Lens" },
    }
  }, { prefix = "<leader>" })
  --map("n", "df", "<cmd>lua vim.lsp.buf.format()<cr>", map_opts)
  --map("n", "gd", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", map_opts)
  -- map("n", "dt", "<cmd>lua vim.lsp.buf.definition()<cr>", map_opts)
  -- map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", map_opts)
  -- map("n", "gD", "<cmd>lua vim.lsp.buf.implementation()<cr>", map_opts)
  -- map("n", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", map_opts)
  -- map("n", "1gD", "<cmd>lua vim.lsp.buf.type_definition()<cr>", map_opts)
  -- map("n", "<space>r", "<cmd>vim.lsp.codelens.run()<cr>", map_opts)
end

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = false,
})

mason.setup {}

mason_config.setup {
  ensure_installed = { "tsserver", "tailwindcss", "sumneko_lua", }
}

nvim_lsp.tsserver.setup {
  on_attach = on_attach,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
  cmd = { "typescript-language-server", "--stdio" }
}

nvim_lsp.sumneko_lua.setup {
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      }
    }
  }
}

nvim_lsp.tailwindcss.setup {}

--[[ nvim_lsp.tailwindcss.setup {
  cmd = { "tailwindcss-language-server", "--stdio" },
  filetypes = { "eelixir", "html", "heex", "html-eex", "typescriptreact", "vue", "svelte" },
  init_options = {
    userLanguages = {
      eelixir = "html",
      heex = "html"
    }
  },
  root_dir = nvim_lsp.util.root_pattern('**/tailwind.config.js'),
  settings = {
    tailwindCSS = {
      lint = {
        cssConflict = "warning",
        invalidApply = "error",
        invalidConfigPath = "error",
        invalidScreen = "error",
        invalidTailwindDirective = "error",
        invalidVariant = "error",
        recommendedVariantOrder = "warning"
      },
      validate = true
    }
  }
} ]]

-- nvim_lsp.serverlesside.setup {
--   cmd = { "/Users/johnchristopher/.asdf/installs/nodejs/16.17.1/.npm/lib/node_modules/@serverless-ide/language-server/dist/server.js", "--stdio"},
--   name = 'serverless ide',
--   filetypes = {"yaml"},
--   on_attach = on_attach,
--   root_dir = nvim_lsp.util.root_pattern('serverless.yml'),
-- }

nvim_lsp.graphql.setup {
  on_attach = on_attach,
}

local path_to_elixirls = vim.fn.expand("~/gitprojects/elixir_projects/elixir-ls/release/language_server.sh")
nvim_lsp.elixirls.setup({
  cmd = { path_to_elixirls },
  capabilities = protocol.make_client_capabilities(),
  on_attach = on_attach,
  settings = {
    elixirLS = {
      dialyzerEnabled = true,
      fetchDeps = false,
      enableTestLenses = true,
      suggestSpecs = false,
    },
  },
})
