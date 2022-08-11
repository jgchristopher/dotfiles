local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	Packer_Bootstrap = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

if Packer_Bootstrap then
	require("packer").sync()
end

return require("packer").startup(function(use)
	--- Packer can manage itself
	use("wbthomason/packer.nvim")
	use("folke/tokyonight.nvim")

	use({
		"catppuccin/nvim",
		as = "catppuccin",
	})

	use("kyazdani42/nvim-web-devicons")
	use("kyazdani42/nvim-tree.lua")

	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	------ LSP
	use({
		"neovim/nvim-lspconfig",
		"williamboman/nvim-lsp-installer",
	})

	----- TreeSitter
	use("nvim-treesitter/nvim-treesitter")

	-- autocomplete and snippets
	use({
		"hrsh7th/nvim-cmp",
	})

	use({
		"saadparwaiz1/cmp_luasnip",
		after = "LuaSnip",
	})

	use({
		"hrsh7th/cmp-nvim-lua",
		after = "cmp_luasnip",
	})

	use({
		"hrsh7th/cmp-nvim-lsp",
		after = "cmp-nvim-lua",
	})

	use({
		"hrsh7th/cmp-buffer",
		after = "cmp-nvim-lsp",
	})

	use({
		"hrsh7th/cmp-path",
		after = "cmp-buffer",
	})

	use("onsails/lspkind-nvim")

	use("folke/trouble.nvim")

	use("nvim-lua/plenary.nvim")
	use("nvim-telescope/telescope.nvim")

	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })

	use({
		"akinsho/bufferline.nvim",
		tag = "v1.1.1",
	})

	use({
		"max397574/better-escape.nvim",
		config = function()
			require("better_escape").setup()
		end,
	})
	use({ "lukas-reineke/indent-blankline.nvim" })
	

	use({ "ellisonleao/glow.nvim", branch = "main" })

	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { hl = "DiffAdd", text = "│", numhl = "GitSignsAddNr" },
					change = { hl = "DiffChange", text = "│", numhl = "GitSignsChangeNr" },
					delete = { hl = "DiffDelete", text = "", numhl = "GitSignsDeleteNr" },
					topdelete = { hl = "DiffDelete", text = "‾", numhl = "GitSignsDeleteNr" },
					changedelete = { hl = "DiffChangeDelete", text = "~", numhl = "GitSignsChangeNr" },
				},
			})
		end,
	})

	use({ "cljoly/telescope-repo.nvim" })
	use({ "nvim-telescope/telescope-ui-select.nvim" })
	use({ "nvim-telescope/telescope-file-browser.nvim" })
	use({ "LinArcX/telescope-command-palette.nvim" })
	use({
		"AckslD/nvim-neoclip.lua",
		config = function()
			require("neoclip").setup()
		end,
	})
	use("nvim-treesitter/nvim-treesitter-refactor")
	use("rafamadriz/friendly-snippets")
	use("L3MON4D3/LuaSnip")

	-- CheatSheet
	use({
		"sudormrfbin/cheatsheet.nvim",
		requires = {
			{ "nvim-telescope/telescope.nvim" },
			{ "nvim-lua/popup.nvim" },
			{ "nvim-lua/plenary.nvim" },
		},
	})

	--debugging
	use("mfussenegger/nvim-dap")
	use("rcarriga/nvim-dap-ui")
	use("theHamsta/nvim-dap-virtual-text")
	use("nvim-telescope/telescope-dap.nvim")

	-- Comment
	use({
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	})

	-- Database
	use { 'tpope/vim-dadbod' }
	use { 'kristijanhusak/vim-dadbod-ui' }
  use { 'kristijanhusak/vim-dadbod-completion' }

  -- Neogit
  use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }

end)
