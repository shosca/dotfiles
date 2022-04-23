local wezterm = require("wezterm")

local foreground = "#a9b1d6"
local background = "#0f111a"
-- local regular0 = "#32344a" -- black
local regular0 = background -- black
local regular1 = "#f7768e" -- red
local regular2 = "#9ece6a" -- green
local regular3 = "#e0af68" -- yellow
local regular4 = "#7aa2f7" -- blue
local regular5 = "#ad8ee6" -- magenta
local regular6 = "#449dab" -- cyan
-- local regular7 = "#787c99" -- white
local regular7 = foreground -- white
local bright0 = "#444b6a" -- bright black
local bright1 = "#ff7a93" -- bright red
local bright2 = "#b9f27c" -- bright green
local bright3 = "#ff9e64" -- bright yellow
local bright4 = "#7da6ff" -- bright blue
local bright5 = "#bb9af7" -- bright magenta
local bright6 = "#0db9d7" -- bright cyan
local bright7 = "#acb0d0" -- bright white

return {
	enable_wayland = true,
	-- window_decorations = "NONE",
	colors = {
		foreground = foreground,
		background = background,
		cursor_bg = "#ffcc00",
		cursor_border = "#ffcc00",
		cursor_fg = "#0f111a",
		selection_bg = "#1f2233",
		selection_fg = "#8f93a2",
		ansi = { regular0, regular1, regular2, regular3, regular4, regular5, regular6, regular7 },
		brights = { bright0, bright1, bright2, bright3, bright4, bright5, bright6, bright7 },
	},
	warn_about_missing_glyphs = false,
	--  font = wezterm.font("Liga SFMono Nerd Font"),
	-- font = wezterm.font("Fira Code"),
	font = wezterm.font("Hasklig"),
	font_size = 10,
	enable_tab_bar = false,
	exit_behavior = "Close",
	-- default_prog = {"tmux"},
	unzoom_on_switch_pane = true,
	-- leader = {key = "`", mods = "", timeout_milliseconds = 500},
	-- keys = {
	--   {key = "`", mods = "LEADER", action = wezterm.action {SendString = "`"}},
	--   {key = "\\", mods = "LEADER", action = wezterm.action {SplitHorizontal = {domain = "DefaultDomain"}}},
	--   {key = "-", mods = "LEADER", action = wezterm.action {SplitVertical = {domain = "DefaultDomain"}}},
	--   {key = "c", mods = "LEADER", action = wezterm.action {SpawnTab = "DefaultDomain"}},
	--   {key = "j", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Next"}},
	--   {key = "k", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Prev"}},
	--   {key = "n", mods = "LEADER", action = wezterm.action {ActivateTabRelative = 1}},
	--   {key = "p", mods = "LEADER", action = wezterm.action {ActivateTabRelative = -1}}
	-- }
}
