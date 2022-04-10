
local ok, null_ls = pcall(require("null-ls"))
if not ok then
  print(vim.inspect(null_ls))
  print('not OK')
end
local b = null_ls.builtins

local sources = {

	b.formatting.prettierd.with({ filetypes = { "html", "markdown", "css", "typescript", "typescriptreact" } }),
	b.formatting.deno_fmt,

	-- Lua
	b.formatting.stylua,
	b.diagnostics.luacheck.with({ extra_args = { "--global vim" } }),

	-- Shell
	b.formatting.shfmt,
	b.diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),
}

local M = {}

M.setup = function()
	null_ls.setup({
		debug = true,
		sources = sources,

		-- format on save
		on_attach = function(client)
			if client.resolved_capabilities.document_formatting then
				vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
			end
		end,
	})
end

return M
