return {
  -- edit lsp keymaps
  -- {
  --   "neovim/nvim-lspconfig",
  --   init = function()
  --     local keys = require("lazyvim.plugins.lsp.keymaps").get()
  --     -- change a keymap
  --     keys[#keys + 1] = { "<leader>cd", false }
  --     keys[#keys + 1] = { "<c-k>", mode = "i", false }
  --   end,
  -- },
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    keys = {
      { "<leader>cd", "<cmd>Lspsaga finder<cr>", desc = "LspSaga Finder" },
      { "<leader>cp", "<cmd>Lspsaga peek_definition<cr>", desc = "LspSaga Peek Definition" },
    },
    config = {
      lightbulb = {
        enable = false,
      },
      outline = {
        win_position = "right",
        win_with = "",
        win_width = 30,
        preview_width = 0.4,
        show_detail = true,
        auto_preview = true,
        auto_refresh = true,
        auto_close = true,
        auto_resize = false,
        custom_sort = nil,
        keys = {
          expand_or_jump = "o",
          quit = "q",
        },
      },
    },
  },
}
