local M = {}

M.setup_lsp = function(attach, capabilities)
	local lspconfig = require("lspconfig")

        local on_attach_elixir = function(client, bufnr)
          attach(client, bufnr)
          client.resolved_capabilities.document_formatting = true
          client.resolved_capabilities.document_range_formatting = true
        end
        lspconfig.elixirls.setup({
		cmd = { "/Users/johnchristopher/.local/share/nvim/lsp_servers/elixir/elixir-ls/language_server.sh" },
		-- cmd = { "/Users/johnchristopher/gitprojects/elixir_projects/elixir-ls/release/language_server.sh" },
		on_attach = on_attach_elixir,
		capabilities = capabilities,
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
		on_attach = attach,
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

	-- lspservers with default config
	local servers = { "html", "cssls", "tsserver" }

	for _, lsp in ipairs(servers) do
		lspconfig[lsp].setup({
			on_attach = attach,
			capabilities = capabilities,
			flags = {
				debounce_text_changes = 150,
			},
		})
	end
end

return M
