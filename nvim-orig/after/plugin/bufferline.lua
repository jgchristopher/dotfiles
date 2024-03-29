local status, bufferline = pcall(require, 'bufferline')
local status2, bufdelete = pcall(require, 'bufdelete')
if (not status and not status2) then return end

bufferline.setup {
  options = {
    mode = "buffers",
    numbers = "buffer_id",
    close_command = function(bufnum)
      bufdelete.bufdelete(bufnum, true)
    end,
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        text_align = "left"
      }
    },
    buffer_close_icon = "",
    modified_icon = "",
    close_icon = "",
    show_close_icon = true,
    left_trunc_marker = "",
    right_trunc_marker = "",
    max_name_length = 14,
    max_prefix_length = 13,
    tab_size = 20,
    show_tab_indicators = true,
    enforce_regular_tabs = false,
    view = "multiwindow",
    show_buffer_close_icons = true,
    separator_style = "thin",
    always_show_bufferline = true,
    diagnostics = "nvim_lsp",
    sort_by = "directory"
  }
}
