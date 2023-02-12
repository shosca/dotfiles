return {
  "MunifTanjim/exrc.nvim",
  config = function()
    require("exrc").setup({
      files = {
        ".nvimrc.lua",
        ".nvimrc",
        ".exrc.lua",
        ".exrc",
      },
    })
  end,
}
