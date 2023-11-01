return {
  {
    "elixir-tools/elixir-tools.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local elixir = require("elixir")
      --local elixirls = require("elixir.elixirls")

      elixir.setup({
        nextls = {
          enable = true,
          init_options = {
            mix_env = "dev",
            mix_target = "host",
            experimental = {
              completions = {
                enable = true, -- control if completions are enabled. defaults to false
              },
            },
          },
        },
        credo = {},
        elixirls = {
          enable = false,
        },
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        ensure_installed = {
          "elixir",
          "heex",
          "surface",
          "erlang",
          "glimmer",
        },
      },
    },
  },
}
