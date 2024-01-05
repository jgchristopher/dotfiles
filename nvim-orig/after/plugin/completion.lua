local status, cmp = pcall(require, 'cmp')
if (not status) then return end

local status2, lspkind = pcall(require, 'lspkind')
if (not status2) then return end

local status3, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
if (not status3) then return end

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  formatting = {
    format = lspkind.cmp_format({ wirth_text = false, maxwidth = 50 })
  },
  -- formatting = {
  -- 	format = function(entry, vim_item)
  -- 		local icons = require("user.lspkind_icons")
  -- 		vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)
  --
  -- 		vim_item.menu = ({
  -- 			nvim_lsp = "[LSP]",
  -- 			nvim_lua = "[Lua]",
  -- 			buffer = "[BUF]",
  -- 		})[entry.source.name]
  --
  -- 		return vim_item
  -- 	end,
  -- },
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
    { name = "nvim_lua" },
    { name = "path" },
    { name = "buffer", keyword_length = 5 },
  },
})

cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

vim.cmd [[
  set completeopt=menuone,noinsert,noselect
  highlight! default link CmpItemKind CmpItemMenuDefault
]]
vim.api.nvim_exec(
  [[
      autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni
      autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })
  ]],
  false
)
