return {
  "nvim-telescope/telescope-project.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("telescope").load_extension("project")
  end,
}
