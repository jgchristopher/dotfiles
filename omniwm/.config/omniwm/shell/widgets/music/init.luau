-- Now playing (Sonos, then Music.app) from bin/current-song, pushed by
-- sketchybar plugins/music.sh. The built-in `media` widget can't see Sonos.
local sb = require("../lib/sb")

function render(ctx)
    local v = sb.var(ctx, "music")
    if not v or not v.label then
        return sb.hidden()
    end
    return sb.chip{ icon = "♪", iconColor = sb.color.magenta, label = v.label, maxWidth = 220,
        labelColor = sb.color.fg }
end
