local utils = require "sh.utils"
return {
  "nvim-pack/nvim-spectre",
  cmd = "Spectre",
  opts = { open_cmd = "noswapfile vnew" },
  keys = {
    {
      "<leader>sr",
      utils.bind("spectre", "open"),
      desc = "Replace in files (Spectre)",
    },
  },
}
