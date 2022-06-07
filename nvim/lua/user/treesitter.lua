local treeSitterConfigs = require("nvim-treesitter.configs")

treeSitterConfigs.setup({
  ensure_installed = {
    "lua",
    "elixir",
    "python",
    "erlang",
    "gleam",
    "surface",
    "eex",
    "css", "scss", "heex", "javascript", "typescript", "html", "json", "yaml", "lua", "rust", "graphql"
  },
  highlight = {
    enable = true,
  },
})

