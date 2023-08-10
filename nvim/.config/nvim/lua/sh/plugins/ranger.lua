return {
  "kelly-lin/ranger.nvim",
  opts = { replace_netrw = true },
  keys = {
    {
      "<leader>ef",
      function()
        require("ranger-nvim").open(true)
      end,
      desc = "Open ranger",
    },
  },
}
