local dap = require('dap')

local path_to_elixirls = vim.fn.expand("~/gitprojects/elixir_projects/elixir-ls/release/debugger.sh")
dap.adapters.mix_task = {
  type = 'executable',
  command = path_to_elixirls, -- debugger.bat for windows
  args = {}
}

dap.configurations.elixir = {
  {
    type = "mix_task",
    name = "mix test",
    task = 'test',
    taskArgs = {"--trace"},
    request = "launch",
    startApps = true, -- for Phoenix projects
    projectDir = "${workspaceFolder}",
    requireFiles = {
      "test/**/test_helper.exs",
      "test/**/*_test.exs"
    }
  },
}

require("dapui").setup()
