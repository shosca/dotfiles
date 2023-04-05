return {
  "ruifm/gitlinker.nvim",
  config = function()
    require("gitlinker").setup()
    require("sh.keymap").nmap({
      "<leader>gb",
      function()
        require("gitlinker").get_buf_range_url("n", {
          action_callback = require("gitlinker.actions").open_in_browser,
        })
      end,
      { silent = true },
    })
  end,
}