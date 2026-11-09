-- Claude 5h rate-limit gauge, pushed by sketchybar plugins/usage.sh.
-- The script decides visibility (>=70%, fresh cache) and level (yellow/orange/red).
local sb = require("../lib/sb")

function render(ctx)
    local v = sb.var(ctx, "usage")
    if not v or not v.label then
        return sb.hidden()
    end
    return sb.chip{ symbol = "gauge.with.dots.needle.67percent", label = v.label, tone = sb.tone(v.level) }
end
