local dap = require('dap')

local function debugPhoenix()
  print("Starting debugger for Phoenix project")
  dap.run({
    type = "mix_task",
    name = "phx.server",
    request = "launch",
    task = "phx.server",
    projectDir = "${workspaceFolder}"
  })
end

local function debugTests()
  print("Starting debugger for tests")
  dap.run({
    type = "mix_task",
    name = "mix test",
    task = 'test',
    taskArgs = { "--trace" },
    request = "launch",
    startApps = true, -- for Phoenix projects
    projectDir = "${workspaceFolder}",
    requireFiles = {
      "test/**/test_helper.exs",
      "test/**/*_test.exs"
    }
  })
end

return {
  dbgPhoenix = debugPhoenix,
  dbgTests = debugTests
}
