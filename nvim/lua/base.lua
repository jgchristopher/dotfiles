local opt = vim.opt
local g = vim.g

opt.title = true
opt.cmdheight = 1
opt.showcmd = true
opt.backup = false
opt.wrap = false
opt.clipboard = "unnamedplus"

opt.mouse = "a"
opt.ignorecase = true
opt.smartcase = true

opt.list = true
opt.number = true
opt.relativenumber = true
opt.autoindent = true

opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.splitbelow = true
opt.splitright = true

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 10

-- experimental
opt.backspace = 'start,eol,indent'

g.glow_border = "rounded"

-- g.catppuccin_flavour = "mocha"
-- g.catppuccin_flavour = "frappe"
g.catppuccin_flavour = "macchiato"
-- g.catppuccin_flavour = "latte"
require("catppuccin").setup({
  dim_inactive = {
    enabled = false,
    shade = "dark",
    percentage = 0.15,
  },
  transparent_background = false,
  term_colors = false,
  compile = {
    enabled = false,
    path = vim.fn.stdpath "cache" .. "/catppuccin",
  },
  styles = {
    comments = {}, -- { "italic" },
    conditionals = {}, -- { "italic" },
    loops = {},
    functions = {},
    keywords = {},
    strings = {},
    variables = {},
    numbers = {},
    booleans = {},
    properties = {},
    types = {},
    operators = {},
  },
  integrations = {
    treesitter = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = {}, -- { "italic" },
        hints = {}, -- { "italic" },
        warnings = {}, -- { "italic" },
        information = {}, -- { "italic" },
      },
      underlines = {
        errors = { "underline" },
        hints = { "underline" },
        warnings = { "underline" },
        information = { "underline" },
      },
    },
    coc_nvim = false,
    lsp_trouble = true,
    cmp = true,
    lsp_saga = false,
    gitgutter = false,
    gitsigns = true,
    leap = false,
    telescope = true,
    nvimtree = true,
    neotree = {
      enabled = false,
      show_root = true,
      transparent_panel = false,
    },
    dap = {
      enabled = true,
      enable_ui = true,
    },
    which_key = false,
    indent_blankline = {
      enabled = false,
      colored_indent_levels = false,
    },
    dashboard = false,
    neogit = true,
    vim_sneak = false,
    fern = false,
    barbar = false,
    bufferline = {
      enabled = false,
      italics = false, -- true,
      bolds = true,
    },
    markdown = true,
    lightspeed = false,
    ts_rainbow = false,
    hop = false,
    notify = true,
    telekasten = true,
    symbols_outline = true,
    mini = false,
    aerial = false,
    vimwiki = true,
    beacon = true,
    navic = false,
    overseer = false,
  },
  color_overrides = {},
  highlight_overrides = {},
  custom_highlights = {
    -- Treesitter
    TSParameter = { style = {} },
    ErrorMsg = { style = {} },
  },
})
vim.cmd([[colorscheme catppuccin]])
