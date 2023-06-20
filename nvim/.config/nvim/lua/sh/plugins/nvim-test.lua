return {
  "klen/nvim-test",
  config = function()
    require("nvim-test").setup({
      termOpts = {
        direction = "horizontal",
      },
    })
  end,
}
