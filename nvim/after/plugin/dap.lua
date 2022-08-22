local dap = require('dap')

local path_to_elixirls = vim.fn.expand("~/gitprojects/elixir_projects/elixir-ls/release/debugger.sh")
dap.adapters.mix_task = {
  type = 'executable',
  command = path_to_elixirls,
  args = {}
}

vim.fn.sign_define('DapBreakpoint', { text = '⛑️j', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', {text='⭐️', texthl='', linehl='', numhl=''})

local dapui = require("dapui")

dapui.setup()
-- dap.listeners.after.event_initialized["dapui_config"] = function()
--   dapui.open()
-- end
-- dap.listeners.before.event_terminated["dapui_config"] = function()
--   dapui.close()
-- end
-- dap.listeners.before.event_exited["dapui_config"] = function()
--   dapui.close()
-- end

