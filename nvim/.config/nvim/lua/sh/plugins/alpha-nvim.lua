return {
  "goolord/alpha-nvim",
  dependencies = { "kyazdani42/nvim-web-devicons" },
  config = function()
    require("alpha").setup(require("alpha.themes.startify").config)
    require("alpha").start(true)
  end,
}
