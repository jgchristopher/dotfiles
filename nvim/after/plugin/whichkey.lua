local status, wk = pcall(require, 'which-key')
local status2, tl_builtin = pcall(require, 'telescope.builtin')
if (not status) then return end
if (not status2) then return end

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
    b = { function() tl_builtin.buffers() end, "Buffers" }, -- create a binding with label
    r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File"}, -- additional options for creating the keymap
    n = { "New File" }, -- just a label. don't create any mapping
    e = "Edit File", -- same as above
    ["1"] = "which_key_ignore",  -- special label to hide it in the popup
  },
}, { prefix = "<leader>" })
