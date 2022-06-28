local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt

--------------------- LSP and Other Stuff --------------------------------------

-- local path_to_elixirls = fn.expand("~/.local/share/nvim/lsp_servers/elixir/elixir-ls/language_server.sh")
local path_to_elixirls = fn.expand("~/gitprojects/elixir_projects/elixir-ls/release/language_server.sh")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_attach = function(_, bufnr)
	local function map(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end

	local map_opts = { noremap = true, silent = true }

	map("n", "df", "<cmd>lua vim.lsp.buf.formatting()<cr>", map_opts)
	map("n", "gd", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>", map_opts)
	map("n", "dt", "<cmd>lua vim.lsp.buf.definition()<cr>", map_opts)
	map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", map_opts)
	map("n", "gD", "<cmd>lua vim.lsp.buf.implementation()<cr>", map_opts)
	map("n", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", map_opts)
	map("n", "1gD", "<cmd>lua vim.lsp.buf.type_definition()<cr>", map_opts)
end

local lspconfig = require("lspconfig")

lspconfig.elixirls.setup({
	cmd = { path_to_elixirls },
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		elixirLS = {
			dialyzerEnabled = true,
			fetchDeps = false,
			enableTestLenses = false,
			suggestSpecs = false,
		},
	},
})

lspconfig.tailwindcss.setup({
	cmd = { "tailwindcss-language-server", "--stdio" },
	--    cmd = { "/Users/johnchristopher/.local/share/nvim/lsp_servers/tailwindcss_npm", "--stdio" },
	filetypes = {
		"eelixir",
		"html",
		"heex",
		"html-eex",
		"javascript",
		"javascriptreact",
		"reason",
		"rescript",
		"typescript",
		"typescriptreact",
		"vue",
		"svelte",
	},
	init_options = {
		userLanguages = {
			elixir = "html",
			eelixir = "html",
			heex = "html",
		},
	},
	root_dir = lspconfig.util.root_pattern("**/tailwind.config.js"),
	settings = {
		tailwindCSS = {
			lint = {
				cssConflict = "warning",
				invalidApply = "error",
				invalidConfigPath = "error",
				invalidScreen = "error",
				invalidTailwindDirective = "error",
				invalidVariant = "error",
				recommendedVariantOrder = "warning",
			},
			validate = true,
		},
	},
})

-- lua lsp!
-- sumneko_lua/extension/server/bin/lua-language-server
local sumneko_root_path = "/Users/johnchristopher/.local/share/nvim/lsp_servers/sumneko_lua"
local sumneko_binary = sumneko_root_path .. "/extension/server/bin/lua-language-server"

lspconfig.sumneko_lua.setup({
	cmd = { sumneko_binary, "-E", sumneko_root_path .. "/extension/server/bin/main.lua" },
	-- on_attach = on_attach,
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
	end,
	capabilities = capabilities,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
				},
				maxPreload = 100000,
				preloadFileSize = 10000,
			},
		},
	},
})

lspconfig.pylsp.setup({
	cmd = { "pylsp" },
	filetypes = { "python" },
	settings = {
		pyls = {
			configurationSources = { "flake8" },
			plugins = {
				jedi_completion = { enabled = true },
				jedi_hover = { enabled = true },
				jedi_references = { enabled = true },
				jedi_signature_help = { enabled = true },
				jedi_symbols = { enabled = true, all_scopes = true },
				pycodestyle = { enabled = false },
				flake8 = {
					enabled = true,
					ignore = {},
					maxLineLength = 160,
				},
				mypy = { enabled = false },
				isort = { enabled = false },
				yapf = { enabled = false },
				pylint = { enabled = false },
				pydocstyle = { enabled = false },
				mccabe = { enabled = false },
				preload = { enabled = false },
				rope_completion = { enabled = false },
			},
		},
	},
	on_attach = on_attach,
})

-- lspservers with default config
local servers = { "html", "cssls", "tsserver" }

for _, lsp in ipairs(servers) do
	lspconfig[lsp].setup({
		on_attach = on_attach,
		capabilities = capabilities,
		flags = {
			debounce_text_changes = 150,
		},
	})
end
