local utils = require("sh.utils")

return {
  "folke/noice.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
    "stevearc/dressing.nvim",
  },
  config = function()
    require("noice").setup()
    local notify = require("notify")
    notify.setup({
      background_colour = "#000000",
    })
    utils.require("telescope", function(m)
      m.load_extension("notify")
    end)
  end,
}
