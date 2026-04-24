-- Picks the active LazyVim colorscheme based on macOS appearance:
--   Dark  → tokyonight-night     (matches Ghostty dark theme)
--   Light → solarized-osaka-day  (high-contrast Solarized Light variant)
--
-- Catppuccin is no longer the active scheme but is still useful as a soft
-- fallback if other schemes fail to load — keeping the spec but without
-- transparent_background so it doesn't fight light-mode contrast.
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
      transparent_background = false,
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
        dap = { enabled = true, enable_ui = true },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      if os_is_dark() then
        opts.colorscheme = "tokyonight-night"
      else
        opts.colorscheme = "solarized-osaka-day"
      end
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = { theme = "auto" },
    },
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#1a1b26",
    },
  },
}
