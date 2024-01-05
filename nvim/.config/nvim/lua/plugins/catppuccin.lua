local os_is_dark = function()
  return (vim.call(
    "system",
    [[echo $(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo 'dark' || echo 'light')]]
  )):find("dark") ~= nil
end

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
      integrations = {
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
  },
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      if os_is_dark() then
        -- colorscheme catppuccin " catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
        opts.colorscheme = "catppuccin-mocha"
      else
        opts.colorscheme = "catppuccin-latte"
      end
    end,
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
