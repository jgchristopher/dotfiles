local M = {}

function M.setup()
  -- Indicate first time installation
  local packer_bootstrap = false

  -- packer.nvim configuration
  local conf = {
    display = {
      open_fn = function()
        return require("packer.util").float { border = "rounded" }
      end,
    },
  }

  -- Check if packer.nvim is installed
  -- Run PackerCompile if there are changes in this file
  local function packer_init()
    local fn = vim.fn
    local cmd = vim.cmd
    local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
      packer_bootstrap = fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
      }
      cmd [[packadd packer.nvim]]
    end
    cmd "autocmd BufWritePost plugins.lua source <afile> | PackerCompile"
  end

  -- Plugins
  local function plugins(use)
    use { "wbthomason/packer.nvim" }

    use("folke/tokyonight.nvim")

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
      "L3MON4D3/LuaSnip",
      after = "nvim-cmp",
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
    use({
      "jose-elias-alvarez/null-ls.nvim",
      after = "nvim-lspconfig",
      config = function()
        require("null-ls").setup({
          sources = {
            require("null-ls").builtins.formatting.stylua,
          },
          on_attach = function(client)
            if client.resolved_capabilities.document_formatting then
              vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
            end
          end,
        })
      end,
    })

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


    if packer_bootstrap then
      print "Restart Neovim required after installation!"
      require("packer").sync()
    end
  end

  packer_init()

  local packer = require "packer"
  packer.init(conf)
  packer.startup(plugins)
end

return M