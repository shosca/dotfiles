local wezterm = require("wezterm")

return {
  enable_wayland = true,
  -- window_decorations="NONE",
  color_scheme = "MaterialOcean",
  warn_about_missing_glyphs = false,
  --  font = wezterm.font("Liga SFMono Nerd Font"),
  -- font = wezterm.font("Fira Code"),
  font = wezterm.font("Hasklig"),
  font_size = 10,
  enable_tab_bar = false,
  exit_behavior = "Close",
  -- default_prog = {"tmux"},
  unzoom_on_switch_pane = true,
  leader = {key = "`", mods = "", timeout_milliseconds = 500},
  keys = {
    {key = "`", mods = "LEADER", action = wezterm.action {SendString = "`"}},
    {key = "\\", mods = "LEADER", action = wezterm.action {SplitHorizontal = {domain = "DefaultDomain"}}},
    {key = "-", mods = "LEADER", action = wezterm.action {SplitVertical = {domain = "DefaultDomain"}}},
    {key = "c", mods = "LEADER", action = wezterm.action {SpawnTab = "DefaultDomain"}},
    {key = "j", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Down"}},
    {key = "k", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Up"}},
    {key = "l", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Right"}},
    {key = "h", mods = "LEADER", action = wezterm.action {ActivatePaneDirection = "Left"}},
    {key = "n", mods = "LEADER", action = wezterm.action {ActivateTabRelative = 1}},
    {key = "p", mods = "LEADER", action = wezterm.action {ActivateTabRelative = -1}}
  }
}
