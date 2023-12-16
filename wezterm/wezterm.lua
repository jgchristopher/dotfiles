-- Pull in the wezterm API
local wezterm = require("wezterm")
local h = require("utils.helpers")
local color_scheme = require("utils.colorscheme")
local w = require("utils/wallpaper")
local b = require("utils.background")
local fonts = require("utils.fonts")

--This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = color_scheme.get_color_scheme()

config.font = fonts.get_font() -- wezterm.font("Monaspace Neon", { weight = "Regular" })
config.font_rules = {
	{
		italic = true,
		font = wezterm.font("Monaspace Radon", { weight = "Bold" }),
	},
}
config.harfbuzz_features = { "calt", "dlig", "clig=1", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08" }
config.font_size = 14.0

-- and finally, return the configuration to wezterm
config.window_decorations = "RESIZE"
config.native_macos_fullscreen_mode = true

-- local wallpaper = "/Users/johnchristopher/Documents/3 - Resources/Wallpapers/simon-spring-PR3GfTli3J4-unsplash.jpg"
config.background = {
	w.get_wallpaper(),

	b.get_background(),
}

-- if h.is_dark() then
-- 	config.background = {
-- 		{
-- 			source = {
-- 				Gradient = {
-- 					orientation = "Horizontal",
-- 					colors = {
-- 						"#00000C",
-- 						"#000026",
-- 						"#00000C",
-- 					},
-- 					interpolation = "CatmullRom",
-- 					blend = "Rgb",
-- 					noise = 0,
-- 				},
-- 			},
-- 			width = "100%",
-- 			height = "100%",
-- 			opacity = 0.95,
-- 		},
-- 		-- {
-- 		-- 	source = {
-- 		-- 		File = { path = wezdir .. "/stars.gif", speed = 0.3 },
-- 		-- 	},
-- 		-- 	repeat_x = "Mirror",
-- 		-- 	-- width = "100%",
-- 		-- 	height = "100%",
-- 		-- 	opacity = 0.95,
-- 		-- 	hsb = {
-- 		-- 		hue = 0.5,
-- 		-- 		saturation = 0.9,
-- 		-- 		brightness = 0.3,
-- 		-- 	},
-- 		-- },
-- 	}
-- end

config.keys = {
	{
		key = "Enter",
		mods = "SHIFT|CTRL",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 50 },
		}),
	},
	{
		key = "|",
		mods = "SHIFT|CTRL",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 50 },
		}),
	},
	{
		key = "w",
		mods = "SHIFT|CTRL",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "{",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Prev"),
	},
	{
		key = "}",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Next"),
	},
	{
		key = "j",
		mods = "CTRL|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Down", 4 }),
	},
	{
		key = "k",
		mods = "CTRL|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Up", 4 }),
	},
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Left", 4 }),
	},
	{
		key = "l",
		mods = "CTRL|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Right", 4 }),
	},
	{ key = "L", mods = "CTRL", action = wezterm.action.ShowDebugOverlay },
}

-- Tab Stuff
config.enable_tab_bar = false
config.use_fancy_tab_bar = false

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local edge_background = "#0b0022"
	local background = "#1b1032"
	local foreground = "#808080"

	if tab.is_active then
		background = "#A13AA1"
		foreground = "#c0c0c0"
	elseif hover then
		background = "#3b3052"
		foreground = "#909090"
	end

	local edge_foreground = background

	local title = tab_title(tab)

	-- ensure that the titles fit in the available space,
	-- and that we have room for the edges.
	title = wezterm.truncate_right(title, max_width - 2)

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

return config
