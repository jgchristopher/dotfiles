-- Open PRs awaiting my review, pushed by sketchybar plugins/github.sh.
-- Neutral chip; the count turns yellow past the script's threshold.
local sb = require("../lib/sb")

local URL = "https://github.com/pulls/review-requested"

local function open(ctx, event)
    omniwm.run("workspace focus-name W")
    omniwm.open(URL)
end

function render(ctx)
    local v = sb.var(ctx, "github")
    if not v or not v.label then
        return sb.hidden()
    end
    local hot = v.level and v.level ~= ""
    return sb.chip{ symbol = "arrow.triangle.pull", iconColor = sb.color.fg, label = v.label,
        labelColor = if hot then sb.tone(v.level).text else sb.color.fg,
        onClick = open, help = "Review requests" }
end
