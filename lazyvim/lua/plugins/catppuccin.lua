return {
  {

    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
      },

      transparent_background = true,
      alpha = true,
      cmp = true,
      gitsigns = true,
      illuminate = true,
      indent_blankline = { enabled = true },
      lsp_trouble = true,
      mini = true,
      native_lsp = {
        enabled = true,
        underlines = {
          errors = { "undercurl" },
          hints = { "undercurl" },
          warnings = { "undercurl" },
          information = { "undercurl" },
        },
      },
      navic = { enabled = true },
      neotest = true,
      noice = true,
      notify = true,
      neotree = true,
      semantic_tokens = true,
      telescope = true,
      treesitter = true,
      which_key = true,
      dap = {
        enabled = true,
        enable_ui = true,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      theme = "catppuccin",
    },
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      transparent_background = true,
      background_colour = "#000000",
    },
  },
}
