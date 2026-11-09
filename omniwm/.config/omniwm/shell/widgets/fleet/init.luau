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

-- `fleet switch <pane>` needs a shell, which widget actions can't run; for now
-- a click only jumps to the D workspace where the agent terminals live.
local function focusAgents(ctx, event)
    omniwm.run("workspace focus-name D")
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
            tone = tone, onClick = focusAgents, help = a.session }
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
                onClick = focusAgents }
        end
    end
    return ui.column(col)
end
