local wezterm = require("wezterm")
local agent_deck = wezterm.plugin.require("https://github.com/Eric162/wezterm-agent-deck")

-- Solarized Dark Patched, matching ~/.config/ghostty/config (background overridden)
local colors = {
  background = "#031219",
  foreground = "#708284",
  cursor_bg = "#708284",
  cursor_fg = "#002831",
  selection_bg = "#002831",
  selection_fg = "#819090",
  ansi = {
    black = "#002831",
    red = "#d11c24",
    green = "#738a05",
    yellow = "#a57706",
    blue = "#2176c7",
    magenta = "#c61c6f",
    cyan = "#259286",
    white = "#eae3cb",
  },
  brights = {
    black = "#475b62",
    red = "#bd3613",
    green = "#475b62",
    yellow = "#536870",
    blue = "#708284",
    magenta = "#5956ba",
    cyan = "#819090",
    white = "#fcf4dc",
  },
}

local config = {
  enable_wayland = true,
  notification_handling = "NeverShow",
  front_end = "WebGpu",
  window_decorations = "INTEGRATED_BUTTONS|RESIZE",
  --window_decorations = "TITLE|RESIZE",
  window_padding = { left = 1, right = 1, top = 0, bottom = 1 },
  --integrated_title_button_alignment = "Left",
  --integrated_title_button_color = colors.ansi.red,
  --integrated_title_buttons = { "Close" },
  max_fps = 170,
  --hide_tab_bar_if_only_one_tab = false,
  enable_scroll_bar = false,
  use_fancy_tab_bar = false,
  --tab_bar_at_bottom = true,
  colors = {
    background = colors.background,
    cursor_bg = colors.cursor_bg,
    cursor_border = colors.cursor_border,
    cursor_fg = colors.ansi.black,
    foreground = colors.foreground,
    selection_bg = colors.selection_bg,
    selection_fg = colors.selection_fg,
    split = colors.ansi.magenta,
    --compose_cursor = "#ff9e64",
    --scrollbar_thumb = "#292e42",
    ansi = {
      colors.ansi.black,
      colors.ansi.red,
      colors.ansi.green,
      colors.ansi.yellow,
      colors.ansi.blue,
      colors.ansi.magenta,
      colors.ansi.cyan,
      colors.ansi.white,
    },
    brights = {
      colors.brights.black,
      colors.brights.red,
      colors.brights.green,
      colors.brights.yellow,
      colors.brights.blue,
      colors.brights.magenta,
      colors.brights.cyan,
      colors.brights.white,
    },
    tab_bar = {
      background = colors.ansi.black,
      active_tab = {
        bg_color = colors.ansi.cyan,
        fg_color = colors.ansi.black,
      },
      inactive_tab = {
        bg_color = colors.ansi.black,
        fg_color = colors.brights.white,
      },
      new_tab = {
        bg_color = colors.ansi.black,
        fg_color = colors.brights.white,
      },
    },
  },
  -- Ghostty keeps bold ANSI colors on their base palette entry; don't remap to brights
  bold_brightens_ansi_colors = false,
  --dpi = 192,
  default_cursor_style = "BlinkingBar",
  window_background_opacity = 0.900,
  wayland_window_background_blur = true,
  warn_about_missing_glyphs = false,
  font = wezterm.font({
    -- family = "Fira Code",
    -- family = "Cascadia Code",
    -- family = "JetBrains Mono",
    -- family = "Monaspace Neon",
    family = "VictorMono Nerd Font Mono",
    -- family = "Ioskeley Mono",
    -- family = "Lilex",
    -- family = "NeoSpleen Nerd Font",
    -- family = "Hasklig",
    -- family = "Iosevka Term SS18",
    -- family = "Monaco",
    -- family = "0xProto Nerd Font",
    -- family = "Google Sans Regular",
    weight = 600,
    harfbuzz_features = {
      "calt=1",
      "clig=1",
      "liga=1",
      "ss01=1",
      "ss02=1",
      "ss03=1",
      "ss04=1",
      "ss05=1",
      "ss06=1",
      "ss07=1",
      "ss08=1",
      "ss09=1",
      "ss10=1",
    },
  }),
  font_size = 10,
  freetype_load_flags = "FORCE_AUTOHINT",
  exit_behavior = "Close",
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
    { key = "1", mods = "LEADER", action = wezterm.action.ActivateTab(0) },
    { key = "2", mods = "LEADER", action = wezterm.action.ActivateTab(1) },
    { key = "3", mods = "LEADER", action = wezterm.action.ActivateTab(2) },
    { key = "4", mods = "LEADER", action = wezterm.action.ActivateTab(3) },
    { key = "5", mods = "LEADER", action = wezterm.action.ActivateTab(4) },
    { key = "6", mods = "LEADER", action = wezterm.action.ActivateTab(5) },
    { key = "7", mods = "LEADER", action = wezterm.action.ActivateTab(6) },
  },
  -- ghostty parity: copy-on-select = clipboard copies the selection to both
  -- the system clipboard and the primary selection, and still opens links.
  -- ClearSelection drops the highlight once the text is copied.
  mouse_bindings = {
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "NONE",
      action = wezterm.action.Multiple({
        wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor("ClipboardAndPrimarySelection"),
        wezterm.action.ClearSelection,
      }),
    },
  },
}

-- Claude Code hyperlinks the filename in its tool-call headers, but paths it prints in prose
-- stay plain text. Match `some/path.py:42` so the open-uri handler below can reach those too.
-- Requires at least one slash, which keeps a bare `package.json` in prose from becoming a link.
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
  regex = [[([\w.@+~-]*(?:/[\w.@+-]+)+)(?::(\d+))?]],
  format = "file://$1#$2",
})

-- Status dots in tab titles + notifications when an agent waits for input.
agent_deck.apply_to_config(config, {
  update_interval = 1000,

  -- Match the Solarized Dark Patched palette above.
  colors = {
    working = colors.ansi.green,
    waiting = colors.ansi.yellow,
    idle = colors.ansi.blue,
    inactive = colors.brights.black,
  },

  -- The plugin ships empty nerd glyphs; supply ones present in VictorMono NFM.
  icons = {
    style = "nerd",
    nerd = {
      working = "\u{f111}", -- nf-fa-circle
      waiting = "\u{f042}", -- nf-fa-adjust
      idle = "\u{f10c}", -- nf-fa-circle_o
      inactive = "\u{f0766}", -- nf-md-circle_outline
    },
  },

  -- WezTerm's native toast never expires on KDE Plasma (wezterm#7553, #7573),
  -- so disable it; the notify-send handler below honours the timeout instead.
  notifications = { enabled = false },
})

-- The GNOME overview and taskbar read wezterm's window title, which wezterm
-- recomputes from the focused pane. Focusing a zsh split rewrote the title to
-- "zsh", losing which agent the window runs. Name the agent instead by scanning
-- every pane in the window; agent-deck already detects agents per pane.
local AGENTS = {
  claude = { label = "Claude", strip = "^✳%s*" },
  opencode = { label = "OpenCode", strip = "^OC%s*|%s*" },
  codex = { label = "Codex" },
  gemini = { label = "Gemini" },
  aider = { label = "Aider" },
}

wezterm.on("format-window-title", function(_tab, _pane, tabs, _panes, _config)
  local parts = {}
  for _, t in ipairs(tabs) do
    for _, p in ipairs(t.panes) do
      local state = agent_deck.get_agent_state(p.pane_id)
      if state then
        local meta = AGENTS[state.agent_type] or { label = state.agent_type }
        local topic = p.title or ""
        if meta.strip then
          topic = topic:gsub(meta.strip, "")
        end
        parts[#parts + 1] = meta.label .. ": " .. topic
      end
    end
  end
  if #parts == 0 then
    return nil -- no agent in this window: keep wezterm's default title
  end
  return table.concat(parts, "  |  ")
end)

-- wezterm.on("agent_deck.status_changed", function(_, pane, _old, new_status, agent_type)
--   if new_status ~= "waiting" then
--     return
--   end
--   wezterm.background_child_process({
--     "notify-send",
--     "-a",
--     "WezTerm",
--     "-u",
--     "normal",
--     "-t",
--     "4000",
--     (agent_type or "agent") .. " needs input",
--     pane:get_title(),
--   })
-- end)

-- -- Open file:// links in nvim instead of xdg-open, split beside the pane that was clicked.
-- -- Parsed by hand rather than wezterm.url.parse: a relative path yields `file://force/x.py`,
-- -- where a URL parser reads `force` as the host and drops it.
-- wezterm.on("open-uri", function(window, pane, uri)
--   local path, line = uri:match("^file://([^#]*)#?(%d*)$")
--   if not path or path == "" then
--     return true -- not a file link; let wezterm open it normally
--   end
--
--   local cwd = pane:get_current_working_dir()
--   cwd = cwd and (cwd.file_path or tostring(cwd)) or wezterm.home_dir
--   if path:sub(1, 1) == "~" then
--     path = wezterm.home_dir .. path:sub(2)
--   end
--
--   -- A relative path is resolved against the pane's cwd, which is often the wrong worktree.
--   -- Bail rather than open a blank buffer at a path that does not exist.
--   local abs = path:sub(1, 1) == "/" and path or (cwd .. "/" .. path)
--   if #wezterm.glob(abs) == 0 then
--     return true
--   end
--
--   local args = { "nvim" }
--   if line ~= "" then
--     table.insert(args, "+" .. line)
--   end
--   table.insert(args, abs)
--
--   window:perform_action(
--     wezterm.action.SplitPane({ direction = "Right", command = { args = args, cwd = cwd } }),
--     pane
--   )
--   return false -- suppress xdg-open
-- end)

return config
