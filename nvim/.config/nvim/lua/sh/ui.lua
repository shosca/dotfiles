local borders = {
  bottom_left = "╰",
  bottom_right = "╯",
  line_horizontal = "─",
  line_vertical = "│",
  top_left = "╭",
  top_right = "╮",
}

local M = {
  borders = {
    borders.top_left,
    borders.line_horizontal,
    borders.top_right,
    borders.line_vertical,
    borders.bottom_right,
    borders.line_horizontal,
    borders.bottom_left,
    borders.line_vertical,
  },
  borderchars = {
    borders.line_horizontal,
    borders.line_vertical,
    borders.line_horizontal,
    borders.line_vertical,
    borders.top_left,
    borders.top_right,
    borders.bottom_right,
    borders.bottom_left,
  },
}

function M.make_borders(hl_name)
  return {
    { borders.top_left, hl_name },
    { borders.line_horizontal, hl_name },
    { borders.top_right, hl_name },
    { borders.line_vertical, hl_name },
    { borders.bottom_right, hl_name },
    { borders.line_horizontal, hl_name },
    { borders.bottom_left, hl_name },
    { borders.line_vertical, hl_name },
  }
end

return M
