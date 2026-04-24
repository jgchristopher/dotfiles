local os_is_dark = function()
  return (vim.call(
    "system",
    [[echo $(defaults read -globalDomain AppleInterfaceStyle &> /dev/null && echo 'dark' || echo 'light')]]
  )):find("dark") ~= nil
end

-- Transparency only in dark mode — light mode prioritizes contrast.
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = os_is_dark(),
      styles = {
        sidebars = os_is_dark() and "transparent" or "normal",
        floats = os_is_dark() and "transparent" or "normal",
      },
    },
  },
}
