vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
    require("vim.ui.clipboard.osc52").copy("+")(vim.v.event.regcontents)
    require("vim.ui.clipboard.osc52").copy("*")(vim.v.event.regcontents)
  end,
})
