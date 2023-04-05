return {
  "nvim-telescope/telescope-cheat.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("telescope").load_extension("cheat")
  end,
}
