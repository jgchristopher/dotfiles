local mason_status, mason = pcall(require, "mason")
local ms_config_status, mason_config = pcall(require, "mason-lspconfig")
local status, nvim_lsp = pcall(require, "lspconfig")
local status2, wk = pcall(require, "which-key")

if not status then
	return
end
if not status2 then
	print("Missing which-key plugin")
	return
end
if not mason_status then
	return
end
if not ms_config_status then
	return
end

local protocol = require("vim.lsp.protocol")
local capabilities = protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_attach = function(client, _)
	if client.server_capabilities.documentFormattingProvider then
		vim.api.nvim_command([[augroup Format]])
		vim.api.nvim_command([[autocmd! * <buffer>]])
		vim.api.nvim_command([[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()]])
		vim.api.nvim_command([[augroup END]])
	end

	wk.register({
		l = {
			name = "lsp",
			f = { "<cmd>lua vim.lsp.buf.format()<cr>", "Format Code" },
			i = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Go to implementation" },
			r = { "<cmd>Lspsaga rename<cr>", "Rename Variable" },
			d = { "<cmd>Lspsaga lsp_finder<CR>", "Lsp Saga Finder" },
			p = { "<cmd>Lspsaga peek_definition<cr>", "Peek Definition" },
			a = { "<cmd>Lspsaga code_action<cr>", "Code Action" },
			h = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover Doc" },
		},
	}, { prefix = "<leader>" })

	wk.register({
		e = { "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Diagnostic Jump Previous" },
	}, { prefix = "[" })
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

mason.setup({})

mason_config.setup_handlers({
	-- The first entry (without a key) will be the default handler
	-- and will be called for each installed server that doesn't have
	-- a dedicated handler.
	function(server_name) -- default handler (optional)
		require("lspconfig")[server_name].setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
	end,
	-- Next, you can provide a dedicated handler for specific servers.
	-- For example, a handler override for the `rust_analyzer`:
	-- ["rust_analyzer"] = function()
	-- 	require("rust-tools").setup({})
	-- end,
	["elixirls"] = function()
		local path_to_elixirls = vim.fn.expand("~/gitprojects/elixir_projects/elixir-ls/release/language_server.sh")
		nvim_lsp.elixirls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			cmd = { path_to_elixirls }, -- uncomment the local path above and this if you want to use that instead of the mason installed version
		})
	end,
	["lua_ls"] = function()
		nvim_lsp.lua_ls.setup({
			on_attach = on_attach,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
				},
			},
		})
	end,
	["tailwindcss"] = function()
		nvim_lsp.tailwindcss.setup({
			on_attach = on_attach,
			init_options = {
				userLanguages = {
					eelixir = "html", -- These are required if I won't to have tailwindcss suggestions in elixir heex templates
					heex = "html",
				},
			},
			emmetCompletions = true,
			includeLanguages = {
				astro = "html",
			},
		})
	end,
	["emmet_ls"] = function()
		nvim_lsp.emmet_ls.setup({
			capabilities = capabilities,
			filetypes = { "html", "heex", "eelixir", "css", "svelte" },
			init_options = {
				html = {
					options = {
						["bem.enabled"] = true,
					},
				},
			},
		})
	end,
})
