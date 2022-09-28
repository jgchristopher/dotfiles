local status, esc = pcall(require, 'better_escape')
if (not status) then return end

esc.setup {}
