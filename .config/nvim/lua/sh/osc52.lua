vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("sh_osc52", { clear = true }),
  callback = function()
    require("vim.ui.clipboard.osc52").copy("+")(vim.v.event.regcontents)
    require("vim.ui.clipboard.osc52").copy("*")(vim.v.event.regcontents)
  end,
})
