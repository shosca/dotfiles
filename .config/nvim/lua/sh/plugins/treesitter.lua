return {
  {
    -- https://github.com/arborist-ts/arborist.nvim
    "arborist-ts/arborist.nvim",
    config = function()
      require("arborist").setup()
    end,
  },
}
