-- One pill per live agent pane, pushed by sketchybar plugins/fleet_pills.sh as
-- an ordered JSON list of { state, pane, session, task }. First POOL inline,
-- the rest behind a "⋯ +N" chip that opens a popout.
-- Phosphor language: lit edge = active/needs-you; idle stays unlit and quiet.
local sb = require("../lib/sb")

local POOL = 5

local STYLE = {
    waiting = { glyph = "⚠", level = "yellow" },
    asking = { glyph = "?", level = "magenta" },
    done = { glyph = "✓", level = "green" },
    working = { glyph = "◉", level = "glow" },
}

local function style(state)
    local s = STYLE[state]
    if s then
        return s.glyph, sb.tone(s.level)
    end
    local rest = sb.tone(nil)
    return "●", { text = sb.color.grey, border = rest.border, fill = rest.fill }
end

-- Widgets can't run commands, but they can open URLs: fleet://switch/<n> goes
-- to ~/Applications/FleetURL.app (./install.sh fleet-url-handler), which runs
-- bin/fleet-url -> `fleet notification-open %<n>`: switch the most recent tmux
-- client to the pane and bring Ghostty forward. Jump to workspace D first.
local function openPane(pane: string?)
    local n = pane and string.match(pane, "^%%(%d+)$")
    if n then
        omniwm.open("fleet://switch/" .. n)
    end
end

local function focusAgent(ctx, pane)
    local switch = sb.switchTo(ctx, "D")
    return function(_, _)
        sb.run(switch)
        openPane(pane)
    end
end

-- `omniwmctl shell trigger fleet open %5` does the same as clicking that pill.
function trigger(ctx, event)
    if event.name == "open" then
        sb.run(sb.switchTo(ctx, "D"))
        openPane(event.value)
    end
end

local function agents(ctx)
    local list = sb.var(ctx, "fleet")
    if type(list) ~= "table" or #list == 0 then
        return nil
    end
    return list
end

function render(ctx)
    local list = agents(ctx)
    if not list then
        return sb.hidden()
    end
    local row = { gap = 4 }
    for i, a in list do
        if i > POOL then
            break
        end
        local glyph, tone = style(a.state)
        row[#row + 1] = sb.chip{ key = a.pane, icon = glyph, label = string.sub(a.session or "", 1, 20),
            tone = tone, onClick = focusAgent(ctx, a.pane), help = a.session }
    end
    if #list > POOL then
        row[#row + 1] = sb.chip{ icon = "⋯", iconColor = sb.color.grey, label = "+" .. tostring(#list - POOL),
            labelColor = sb.color.grey, popout = true }
    end
    return ui.row(row)
end

function popout(ctx)
    local list = agents(ctx)
    if not list or #list <= POOL then
        return sb.hidden()
    end
    local col = { gap = 4, pad = 8 }
    for i, a in list do
        if i > POOL then
            local glyph, tone = style(a.state)
            local label = (a.session or "") .. " " .. string.sub(a.task or "", 1, 24)
            col[#col + 1] = sb.chip{ key = a.pane, icon = glyph, label = label, tone = tone,
                onClick = focusAgent(ctx, a.pane) }
        end
    end
    return ui.column(col)
end
