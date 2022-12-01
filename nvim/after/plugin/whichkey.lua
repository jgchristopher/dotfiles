local status, wk = pcall(require, 'which-key')
local status2, tl_builtin = pcall(require, 'telescope.builtin')
local status3, tl = pcall(require, 'telescope')
if (not status) then return end
if (not status2) then return end
if (not status3) then return end

wk.setup {
  plugins = {
    presets = true,
    registers = true,
    marks = true
  }
}

local wk = require("which-key")
-- As an example, we will create the following mappings:
--  * <leader>ff find files
--  * <leader>fr show recent files
--  * <leader>fb Foobar
-- we'll document:
--  * <leader>fn new file
--  * <leader>fe edit file
-- and hide <leader>1

wk.register({
  f = {
    name = "file", -- optional group name
    f = { "<cmd>Telescope find_files<cr>", "Find File" }, -- create a binding with label
    g = { function() tl_builtin.live_grep() end, "Live Grep" }, -- create a binding with label
    s = { function() tl_builtin.buffers() end, "Buffers" }, -- create a binding with label
    r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" }, -- additional options for creating the keymap
    b = { function() tl.extensions.file_browser.file_browser({ initial_mode = "normal" }) end, "File Browser" },
  },
  b = {
    n = { "<cmd>bnext<cr>", "Next Buffer" },
    p = { "<cmd>bprevious<cr>", "Previous Buffer" },
  }
}, { prefix = "<leader>" })
