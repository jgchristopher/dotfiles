local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt

--------------------- LSP and Other Stuff --------------------------------------

local path_to_elixirls = fn.expand("~/.local/share/nvim/lsp_servers/elixir/elixir-ls/language_server.sh")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local cmp = require("cmp")
vim.opt.completeopt = "menuone,noselect"

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	formatting = {
		format = function(entry, vim_item)
			local icons = require("plugins.configs.lspkind_icons")
			vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)

			vim_item.menu = ({
				nvim_lsp = "[LSP]",
				nvim_lua = "[Lua]",
				buffer = "[BUF]",
			})[entry.source.name]

			return vim_item
		end,
	},
	mapping = {
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.close(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif require("luasnip").expand_or_jumpable() then
				vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif require("luasnip").jumpable(-1) then
				vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "nvim_lua" },
		{ name = "path" },
	},
})
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

	-- These have a different style than above because I was fiddling
	-- around and never converted them. Instead of converting them
	-- now, I'm leaving them as they are for this article because this is
	-- what I actually use, and hey, it works ¯\_(ツ)_/¯.
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
	on_attach = on_attach,
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
		on_attach = on_attach,
		capabilities = capabilities,
		flags = {
			debounce_text_changes = 150,
		},
	})
end
