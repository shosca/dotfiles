return {
  "numToStr/Comment.nvim",
  config = function()
    require("Comment").setup({
      ignore = nil,
      opleader = { line = "gc", block = "gb" },
      mappings = {
        basic = true, -- Includes `gcc`, `gcb`, `gc[count]{motion}` and `gb[count]{motion}`
        extra = true, -- Includes `gco`, `gcO`, `gcA`
        extended = false, -- Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
      },
      toggler = { line = "gcc", block = "gbc" },
    })
  end,
}