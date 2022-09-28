local status, tree = pcall(require, 'nvim-tree')
if (not status) then return end

tree.setup({
  disable_netrw = true,
  hijack_netrw = true,
  open_on_setup = false,
  ignore_ft_on_setup = {},
  open_on_tab = false,
  hijack_cursor = false,
  update_cwd = true,
  --[[	update_to_buf_dir = {
		enable = true,
		auto_open = true,
	},]] --
  diagnostics = {
    enable = false,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  update_focused_file = {
    enable = false,
    update_cwd = false,
    ignore_list = {},
  },
  system_open = {
    cmd = nil,
    args = {},
  },
  filters = {
    dotfiles = false,
    custom = {},
  },
  view = {
    centralize_selection = true,
    adaptive_size = true,
    width = 30,
    hide_root_folder = false,
    side = "left",
    mappings = {
      custom_only = false,
      list = {},
    },
  },
  respect_buf_cwd = true,
})

 -- Key Bindings for Nvim-Tree
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<Leader>e", ":NvimTreeFocus<CR>")
