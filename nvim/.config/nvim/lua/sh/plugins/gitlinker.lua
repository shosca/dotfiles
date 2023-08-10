return {
  "ruifm/gitlinker.nvim",
  opts = {},
  keys = {
    {
      "<leader>gb",
      function()
        require("gitlinker").get_buf_range_url("n", {
          action_callback = require("gitlinker.actions").open_in_browser,
        })
      end,
      silent = true,
      desc = "Open line in github",
    },
  },
}
