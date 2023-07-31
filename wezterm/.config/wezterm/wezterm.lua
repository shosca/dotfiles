local wezterm = require("wezterm")

local background = "#0f111a"
local foreground = "#c0caf5"
local cursor_bg = "#c0caf5"
local cursor_border = "#c0caf5"
local cursor_fg = "#1a1b26"
local selection_bg = "#283457"
local selection_fg = "#c0caf5"

local black = background
local red = "#f7768e"
local green = "#9ece6a"
local yellow = "#e0af68"
local blue = "#7aa2f7"
local magenta = "#bb9af7"
local cyan = "#7dcfff"
local white = "#a9b1d6"

-- ansi = { black,   white },
-- ansi = [, "]
-- brights = ["", ", "", "", "", "", "", ""]
--
local black_bright = "#414868"
local red_bright = "#f7768e"
local green_bright = "#9ece6a"
local yellow_bright = "#e0af68"
local blue_bright = "#7aa2f7"
local magenta_bright = "#bb9af7"
local cyan_bright = "#7dcfff"
local white_bright = "#c0caf5"

wezterm.on("update-right-status", function(window, pane)
  -- Each element holds the text for a cell in a "powerline" style << fade
  local cells = { "" }

  -- Figure out the cwd and host of the current pane.
  -- This will pick up the hostname for the remote host if your
  -- shell is using OSC 7 on the remote host.
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    cwd_uri = cwd_uri:sub(8)
    local slash = cwd_uri:find("/")
    local cwd = ""
    local hostname = ""
    if slash then
      hostname = cwd_uri:sub(1, slash - 1)
      -- Remove the domain name portion of the hostname
      local dot = hostname:find("[.]")
      if dot then
        hostname = hostname:sub(1, dot - 1)
      end
      -- and extract the cwd from the uri
      cwd = cwd_uri:sub(slash)

      table.insert(cells, cwd)
      table.insert(cells, hostname)
    end
  end

  -- I like my date/time in this style: "Wed Mar 3 08:14"
  local date = wezterm.strftime("%a %b %-d %H:%M")
  table.insert(cells, date)

  -- An entry for each battery (typically 0 or 1 battery)
  for _, b in ipairs(wezterm.battery_info()) do
    table.insert(cells, string.format("%.0f%%", b.state_of_charge * 100))
  end

  -- The powerline < symbol
  local LEFT_ARROW = utf8.char(0xe0b3)
  -- The filled in variant of the < symbol
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

  -- Color palette for the backgrounds of each cell
  local colors = {
    background,
    cyan,
    cyan_bright,
    green,
    green_bright,
    blue,
    blue_bright,
    magenta,
    magenta_bright,
  }

  -- Foreground color for the text across the fade
  local text_fg = black

  -- The elements to be formatted
  local elements = {}
  -- How many cells have been formatted
  local num_cells = 0

  -- Translate a cell into elements
  local function _push(text, is_last)
    local cell_no = num_cells + 1
    table.insert(elements, { Foreground = { Color = text_fg } })
    table.insert(elements, { Background = { Color = colors[cell_no] } })
    table.insert(elements, { Text = " " .. text .. " " })
    if not is_last then
      table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
      table.insert(elements, { Text = SOLID_LEFT_ARROW })
    end
    num_cells = num_cells + 1
  end

  while #cells > 0 do
    local cell = table.remove(cells, 1)
    _push(cell, #cells == 0)
  end

  window:set_right_status(wezterm.format(elements))
end)

return {
  enable_wayland = true,
  front_end = "WebGpu",
  window_frame = {
    active_titlebar_bg = background,
    active_titlebar_border_bottom = background,
    active_titlebar_fg = foreground,
    inactive_titlebar_bg = background,
    inactive_titlebar_border_bottom = background,
    inactive_titlebar_fg = black_bright,
    button_fg = foreground,
    button_bg = background,
    button_hover_fg = background,
    button_hover_bg = red,
  },
  window_padding = {
    left = 1,
    right = 1,
    top = 0,
    bottom = 0,
  },
  window_decorations = "TITLE | RESIZE",
  hide_tab_bar_if_only_one_tab = false,
  use_fancy_tab_bar = false,
  tab_bar_at_bottom = true,
  animation_fps = 1,
  -- window_decorations = "",
  colors = {
    foreground = foreground,
    background = background,
    cursor_bg = cursor_bg,
    cursor_border = cursor_border,
    cursor_fg = cursor_fg,
    selection_bg = selection_bg,
    selection_fg = selection_fg,
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
    tab_bar = {
      background = background,
      active_tab = {
        bg_color = cyan,
        fg_color = background,
      },
      inactive_tab = {
        bg_color = background,
        fg_color = foreground,
      },
      new_tab = {
        bg_color = background,
        fg_color = foreground,
      },
    },
  },
  default_cursor_style = "BlinkingBar",
  xcursor_theme = "Adwaita",
  window_background_opacity = 0.925,
  warn_about_missing_glyphs = false,
  -- font = wezterm.font("Liga SFMono Nerd Font"),
  -- font = wezterm.font("Fira Code"),
  -- font = wezterm.font("Cascadia Code"),
  -- font = wezterm.font("JetBrains Mono"),
  -- font = wezterm.font("Lilex"),
  font = wezterm.font("Hasklig"),
  font_size = 10,
  harfbuzz_features = {
    "cv06=1",
    "cv14=1",
    "cv32=1",
    "ss04=1",
    "ss07=1",
    "ss09=1",
  },
  freetype_load_target = "Light",
  -- enable_tab_bar = false,
  exit_behavior = "Close",
  -- default_prog = {"tmux"},
  unzoom_on_switch_pane = true,
  leader = { key = "`", mods = "", timeout_milliseconds = 500 },
  keys = {
    { key = "`", mods = "LEADER", action = wezterm.action({ SendString = "`" }) },
    { key = "\\", mods = "LEADER", action = wezterm.action({ SplitHorizontal = { domain = "DefaultDomain" } }) },
    { key = "-", mods = "LEADER", action = wezterm.action({ SplitVertical = { domain = "DefaultDomain" } }) },
    { key = "c", mods = "LEADER", action = wezterm.action({ SpawnTab = "DefaultDomain" }) },
    { key = "j", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Next" }) },
    { key = "k", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Prev" }) },
    { key = "n", mods = "LEADER", action = wezterm.action({ ActivateTabRelative = 1 }) },
    { key = "p", mods = "LEADER", action = wezterm.action({ ActivateTabRelative = -1 }) },
    { key = "y", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
  },
}
