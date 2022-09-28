local status, ts = pcall(require, 'nvim-treesitter.configs')
if (not status) then return end



ts.setup({
  ensure_installed = {
    "lua",
    "elixir",
    "python",
    "erlang",
    "gleam",
    "surface",
    "eex",
    "css",
    "scss",
    "heex",
    "javascript",
    "typescript",
    "tsx",
    "html",
    "json",
    "yaml",
    "lua",
    "rust",
    "graphql",
  },
  highlight = {
    enable = true,
    disable = {}
  },
  indent = { enable = true },
  matchup = { enable = true },
  autopairs = { enable = true },
  autotag = {
    enable = true
  },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = 1000,
  },
  refactor = {
    smart_rename = { enable = true, keymaps = { smart_rename = "grr" } },
    highlight_definitions = { enable = true },
    highlight_current_scope = { enable = false },
    navigation = {
      enable = true,
      keymaps = {
        goto_definition_lsp_fallback = "gnd",
        -- use telescope for these lists
        -- list_definitions = "gnD",
        -- list_definitions_toc = "gO",
        -- @TODOUA: figure out if I need both below
        goto_next_usage = "<a-*>", -- is this redundant?
        goto_previous_usage = "<a-#>", -- also this one?
      },
    },
  },
})
