local wezterm = require("wezterm")

local background = "#0f111a"
local foreground = "#a9b1d6"

local black = background
local red = "#f7768e"
local green = "#9ece6a"
local yellow = "#e0af68"
local blue = "#7aa2f7"
local magenta = "#ad8ee6"
local cyan = "#449dab"
local white = foreground
--
local black_bright = "#444b6a"
local red_bright = "#ff7a93"
local green_bright = "#b9f27c"
local yellow_bright = "#ff9e64"
local blue_bright = "#7da6ff"
local magenta_bright = "#bb9af7"
local cyan_bright = "#0db9d7"
local white_bright = "#acb0d0"

return {
  enable_wayland = true,
  window_decorations = "TITLE | RESIZE",
  colors = {
    foreground = foreground,
    background = background,
    cursor_bg = "#ffcc00",
    cursor_border = "#ffcc00",
    cursor_fg = "#0f111a",
    selection_bg = "#1f2233",
    selection_fg = "#8f93a2",
    ansi = { black, red, green, yellow, blue, magenta, cyan, white },
    brights = {
      black_bright,
      red_bright,
      green_bright,
      yellow_bright,
      blue_bright,
      magenta_bright,
      cyan_bright,
      white_bright,
    },
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
