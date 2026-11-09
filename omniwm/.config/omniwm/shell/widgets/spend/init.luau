-- Today's agent spend across claude/codex/pi, pushed by sketchybar plugins/spend.sh.
local sb = require("../lib/sb")

function render(ctx)
    local v = sb.var(ctx, "spend")
    if not v or not v.label then
        return sb.hidden()
    end
    return sb.chip{ icon = "$", iconFont = sb.mono, iconColor = sb.color.grey, label = v.label,
        labelColor = sb.color.fg }
end
