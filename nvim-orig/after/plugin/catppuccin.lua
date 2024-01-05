local status, catppuccin = pcall(require, "catppuccin")
if not status then
	return
end

-- g.catppuccin_flavour = "mocha"
-- g.catppuccin_flavour = "frappe"
vim.g.catppuccin_flavour = "macchiato"
-- g.catppuccin_flavour = "latte"
catppuccin.setup({
	dim_inactive = {
		enabled = false,
		shade = "dark",
		percentage = 0.15,
	},

	transparent_background = true,
	term_colors = false,
	compile = {
		enabled = false,
		path = vim.fn.stdpath("cache") .. "/catppuccin",
	},
	styles = {
		comments = {}, -- { "italic" },
		conditionals = {}, -- { "italic" },
		loops = {},
		functions = {},
		keywords = {},
		strings = {},
		variables = {},
		numbers = {},
		booleans = {},
		properties = {},
		types = {},
		operators = {},
	},
	integrations = {
		treesitter = true,
		native_lsp = {
			enabled = true,
			virtual_text = {
				errors = {}, -- { "italic" },
				hints = {}, -- { "italic" },
				warnings = {}, -- { "italic" },
				information = {}, -- { "italic" },
			},
			underlines = {
				errors = { "underline" },
				hints = { "underline" },
				warnings = { "underline" },
				information = { "underline" },
			},
		},
		coc_nvim = false,
		lsp_trouble = true,
		cmp = true,
		lsp_saga = true,
		gitgutter = false,
		gitsigns = true,
		leap = false,
		telescope = true,
		nvimtree = false,
		neotree = {
			enabled = true,
			show_root = true,
			transparent_panel = true,
		},
		dap = {
			enabled = true,
			enable_ui = true,
		},
		which_key = true,
		indent_blankline = {
			enabled = true,
			colored_indent_levels = true,
		},
		dashboard = false,
		neogit = true,
		vim_sneak = false,
		fern = false,
		barbar = false,
		bufferline = {
			enabled = false,
			italics = false, -- true,
			bolds = true,
		},
		markdown = true,
		lightspeed = false,
		ts_rainbow = false,
		hop = false,
		notify = true,
		telekasten = true,
		symbols_outline = true,
		mini = false,
		aerial = false,
		vimwiki = true,
		beacon = true,
		navic = false,
		overseer = false,
	},
	color_overrides = {},
	highlight_overrides = {},
	custom_highlights = {
		-- Treesitter
		TSParameter = { style = {} },
		ErrorMsg = { style = {} },
	},
})

vim.cmd([[colorscheme catppuccin]])
