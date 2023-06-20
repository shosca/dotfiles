return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    { "kevinhwang91/promise-async" },
  },
  config = function()
    local ufo = require("ufo")
    ufo.setup()
    vim.keymap.set("n", "zR", ufo.openAllFolds)
    vim.keymap.set("n", "zM", ufo.closeAllFolds)
    vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds)
    vim.keymap.set("n", "zm", ufo.closeFoldsWith)
    vim.keymap.set("n", "zp", ufo.peekFoldedLinesUnderCursor)
  end,
}
