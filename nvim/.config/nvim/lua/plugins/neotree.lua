return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    source_selector = {
      winbar = true, -- toggle to show selector on winbar
    },
  },
  -- keys = {
  --   { "<leader>e", false },
  --   {
  --     "<leader>e",
  --     function()
  --       require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
  --     end,
  --     desc = "Explorer NeoTree (cwd)",
  --   },
  --   { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
  -- },
}
