require("lualine").setup({
  options = {
    -- ... your lualine config
    theme = "catppuccin",
    globalstatus = true,
  },
  winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { { 'filename', path = 1 } }
  }

})
