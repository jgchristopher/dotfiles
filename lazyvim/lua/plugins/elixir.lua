return {

  "elixir-tools/elixir-tools.nvim",
  opts = function(_, opts)
    opts.nextls = {
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
    }
    opts.credo = {}
    opts.elixirls = {
      enable = false,
    }
  end,
}
