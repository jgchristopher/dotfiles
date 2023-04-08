local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

	--"folke/tokyonight.nvim",
	{ "catppuccin/nvim", name = "catppuccin" },
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v2.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
	},

	"feline-nvim/feline.nvim",
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	"glepnir/lspsaga.nvim",
	"neovim/nvim-lspconfig",

	----- TreeSitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
	},
	"nvim-treesitter/nvim-treesitter-refactor",
	"nvim-treesitter/nvim-treesitter-context",
	"windwp/nvim-autopairs",
	"windwp/nvim-ts-autotag",
	"jose-elias-alvarez/null-ls.nvim",
	"MunifTanjim/prettier.nvim",

	-- autocomplete and snippets
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
		},
	},
	"rafamadriz/friendly-snippets",
	"onsails/lspkind-nvim",
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
	},

	"folke/trouble.nvim",
	"NvChad/nvim-colorizer.lua",

	-- Telescope
	"nvim-lua/plenary.nvim",
	"nvim-telescope/telescope.nvim",
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	"nvim-telescope/telescope-file-browser.nvim",

	--[[
    "cljoly/telescope-repo.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    { 'akinsho/bufferline.nvim', tag = "v2.*", requires = 'kyazdani42/nvim-web-devicons' },
    'famiu/bufdelete.nvim',
--]]
	--
	"max397574/better-escape.nvim",

	"lukas-reineke/indent-blankline.nvim",

	"lewis6991/gitsigns.nvim",

	-- Comment
	"numToStr/Comment.nvim",

	-- Which Key
	"folke/which-key.nvim",

	"voldikss/vim-floaterm",
	"kylechui/nvim-surround",
	-- Database
	"tpope/vim-dadbod",
	"kristijanhusak/vim-dadbod-ui",
	"kristijanhusak/vim-dadbod-completion",
	"mbbill/undotree",
	{
		"utilyre/barbecue.nvim",
		name = "barbecue",
		version = "*",
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons", -- optional dependency
		},
		opts = {},
	},
	{
		"mawkler/modicator.nvim",
		dependencies = "mawkler/onedark.nvim", -- Add your colorscheme plugin here
		init = function()
			-- These are required for Modicator to work
			vim.o.cursorline = true
			vim.o.number = true
			vim.o.termguicolors = true
		end,
		opts = {},
	},
	--[[
    -- Vim clipboard manager
    use({
      "AckslD/nvim-neoclip.lua",
      require = {
        { 'kkharji/sqlite.lua', module = 'sqlite' },
        { 'nvim-telescope/telescope.nvim' },
      }
    })

    --debugging
    "mfussenegger/nvim-dap",
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-telescope/telescope-dap.nvim",


--]]
})
