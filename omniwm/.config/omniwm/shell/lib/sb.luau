-- Shared look for the widgets mirrored from sketchybar.
--
-- Data is pushed by the sketchybar plugins (sketchybar/.config/sketchybar/
-- plugins/omni_push.sh) as JSON in ctx.data.vars[<widget>]; these widgets only
-- draw. Colors are the same hex as sketchybar/colors.sh (Ayu Dark + the
-- Phosphor ramp) so both bars match while they run side by side.

local M = {}

M.color = {
    fg = "#bfbdb6",
    grey = "#5c6773",
    magenta = "#d2a6ff",
    hairline = "#bfbdb61f", -- resting 1px chip border (12% fg)
    itemBg = "#10161fcc", -- chip fill
}

M.mono = "Monaspace Neon"

-- Semantic hue -> { text, border, fill }, matching colors.sh's ff / e6 / 1f
-- alphas. "glow" is the accent blue (fleet working). Unknown/nil = resting chip.
local HUES = {
    yellow = "ffb454",
    orange = "ff8f40",
    red = "f07178",
    green = "aad94b",
    magenta = "d2a6ff",
    glow = "59c2ff",
}

function M.tone(level: string?)
    local hex = if level then HUES[level] else nil
    if not hex then
        return { text = M.color.fg, border = M.color.hairline, fill = M.color.itemBg }
    end
    local edge = if level == "glow" then "d9" else "e6"
    local fill = if level == "glow" then "24" else "1f"
    return { text = "#" .. hex, border = "#" .. hex .. edge, fill = "#" .. hex .. fill }
end

-- Command that switches to the workspace named `name`, or nil if it doesn't
-- exist. Widget actions only accept omniwmctl *commands*, which address
-- workspaces by id (`workspace focus-name` is rejected and fails the widget).
-- Resolve during render: reading ctx.data.workspaces there subscribes to it.
function M.switchTo(ctx, name: string): string?
    for _, ws in ctx.data.workspaces or {} do
        if ws.name == name then
            return "switch-workspace " .. ws.id
        end
    end
    return nil
end

-- Run an action without letting a rejected command mark the widget failed.
function M.run(command: string?)
    if command then
        local ok, err = pcall(omniwm.run, command)
        if not ok then
            omniwm.log("sb.run failed", command, err)
        end
    end
end

-- What a widget renders while it has nothing to show (render must return an element).
function M.hidden()
    return ui.box{ w = 0, h = 0 }
end

-- The pushed JSON for this widget, or nil when unset/empty/invalid (hide).
function M.var(ctx, key: string): any
    local raw = ctx.data.vars and ctx.data.vars[key]
    if raw == nil or raw == "" then
        return nil
    end
    local value = json.decode(raw)
    return value
end

-- A sketchybar-style chip: optional icon, label, 1px edge, rounded fill.
-- p = { symbol? | icon?, iconColor?, iconFont?, label, labelColor?, tone?, maxWidth?, onClick?, help?, popout? }
function M.chip(p)
    local tone = p.tone or M.tone(nil)
    local row = {
        gap = 6,
        pad = 5,
        radius = 6,
        fill = tone.fill,
        border = tone.border,
        borderWidth = 1,
        key = p.key, -- retained identity for click handlers
        onClick = p.onClick,
        popout = p.popout,
        help = p.help,
    }
    if p.symbol then
        -- SF Symbol: Nerd Font private-use glyphs don't render in OmniShell text
        row[#row + 1] = ui.symbol{ name = p.symbol, size = 12, color = p.iconColor or tone.text }
    elseif p.icon then
        row[#row + 1] = ui.text{
            text = p.icon,
            font = p.iconFont,
            size = 13,
            color = p.iconColor or tone.text,
        }
    end
    row[#row + 1] = ui.text{
        text = p.label,
        font = M.mono,
        size = 12,
        color = p.labelColor or tone.text,
        maxWidth = p.maxWidth,
        lines = 1,
    }
    return ui.row(row)
end

return M
