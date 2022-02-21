return {
   { "williamboman/nvim-lsp-installer" },
   {
      "jose-elias-alvarez/null-ls.nvim",
      after = "nvim-lspconfig",
      config = function()
         require("custom.null-ls").setup()
      end,
   },
   { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
   { "ellisonleao/glow.nvim" },
   { "mhinz/vim-mix-format" },
   {
      "p00f/nvim-ts-rainbow",
      after = "nvim-treesitter",
   },
}
