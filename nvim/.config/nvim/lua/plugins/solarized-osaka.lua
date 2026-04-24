-- Solarized Osaka: solarized variant by craftzdog with active maintenance.
-- Used as the light-mode colorscheme; configured for high contrast (no transparency).
return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = false,
      styles = {
        sidebars = "normal",
        floats = "normal",
      },
    },
  },
}
