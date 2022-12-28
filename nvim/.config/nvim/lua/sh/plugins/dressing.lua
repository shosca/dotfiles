return {
  "stevearc/dressing.nvim",
  config = function()
    require("dressing").setup({
      input = {
        prompt_align = "center",
        anchor = "NW",
        max_width = { 140, 0.9 },
        min_width = { 40, 0.6 },
      },
    })
  end,
}
