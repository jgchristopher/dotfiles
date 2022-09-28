local status, trbl = pcall(require, 'trouble')
if (not status) then return end

trbl.setup {
  width = 50
}
