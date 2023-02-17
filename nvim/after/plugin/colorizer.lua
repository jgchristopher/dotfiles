local status, clrzr = pcall(require, 'colorizer')
if (not status) then return end

clrzr.setup {
  filetypes = {
    'css',
    'javascript',
    html = { mode = 'foreground', }
  },
  user_default_options = { mode = "background", },
  tailwind = true,
}
