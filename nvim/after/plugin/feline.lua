local status, feline = pcall(require, 'feline')
if (not status) then return end

local status_cat, ctp_feline = pcall(require, 'catppuccin.groups.integrations.feline')
if (status_cat) then
  ctp_feline.setup({})
  feline.setup {
    -- catppuccin theme integration
    components = ctp_feline.get(),
  }
  feline.winbar.setup()
  return
end

local status_tokio, _ = pcall(require, 'tokyonight')
if (status_tokio) then
  local _, tky_feline = pcall(require, 'feline-theme-component')
  feline.setup {
    -- tokyonight theme integration
    components = tky_feline.get(),
  }
  return
end
