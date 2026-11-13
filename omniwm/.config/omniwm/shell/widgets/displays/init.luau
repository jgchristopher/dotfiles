-- Connected display count; click opens System Settings > Displays.
-- Stands in for the native Displays menu bar item: it is a Control Center
-- module, and OmniWM drops com.apple.controlcenter from hiddenBundleIDs, so
-- the hidden bar can't hold it.
local sb = require("../lib/sb")

local URL = "x-apple.systempreferences:com.apple.Displays-Settings.extension"

function render(ctx)
    local system = ctx.data.system
    local count = if system then #system.displays else 0
    local function open(_, _)
        omniwm.open(URL)
    end
    return sb.chip{ symbol = "display.2", iconColor = sb.color.fg, label = tostring(count),
        labelColor = sb.color.fg, onClick = open, help = "Displays" }
end
