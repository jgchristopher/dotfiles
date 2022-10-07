local status, telescope = pcall(require, 'telescope')
if (not status) then return end

local actions = require('telescope.actions')

local function telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

local fb_actions = require 'telescope'.extensions.file_browser.actions
local builtin = require('telescope.builtin')

telescope.setup({
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
    file_browser = {
      theme = 'dropdown',
      hijack_netrw = true,
      mappings = {

      }
    },
    repo = {
      list = {
        fd_opts = {
          "--no-ignore-vcs",
        },
        search_dirs = {
          "~/gitprojects/",
        },
      },
    },
  },
  defaults = {
    mappings = {
      n = {
        ['q'] = actions.close,
        ["<C-d>"] = "delete_buffer",
      }
    },
    prompt_prefix = "   ",
    selection_caret = "  ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
        results_width = 0.8,
      },
      vertical = {
        mirror = false,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    file_ignore_patterns = { "node_modules" },
    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
    path_display = { "truncate" },
    winblend = 0,
    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    color_devicons = true,
    use_less = true,
    set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
    file_previewer = require("telescope.previewers").vim_buffer_cat.new,
    grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
    qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
  },
})
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
local extensions = { "fzf", "repo", "file_browser", --[[ "neoclip" --]] }

pcall(function()
  for _, ext in ipairs(extensions) do
    telescope.load_extension(ext)
  end
end)

-- Telescope Key Bindings
-- -- telescope-repo
vim.keymap.set("n", "<leader>rl", ":lua require'user.telescope'.repo_list()")
vim.keymap.set(
  "n",
  "<leader>k",
  ":lua require'telescope'.extensions.command_palette.command_palette()"
)
-- vim.keymap.set(
--   "n",
--   "<leader>n",
--   ":lua require'telescope'.extensions.neoclip.default()"
-- )
vim.keymap.set("n", "<leader>ff", function() require('telescope.builtin').find_files()
end)
vim.keymap.set("n", "<leader>fb", function() telescope.extensions.file_browser.file_browser({
    initial_mode = "normal"
  })
end)
vim.keymap.set("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>")
vim.keymap.set("n", "<leader>sb", function() require('telescope.builtin').buffers({ initial_mode = "normal" }) end)
vim.keymap.set("n", "<leader>di", function() builtin.diagnostics() end)
