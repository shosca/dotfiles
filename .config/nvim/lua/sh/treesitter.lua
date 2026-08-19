vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable treesitter folding",
  group = vim.api.nvim_create_augroup("enable_treesitter", {}),
  callback = function(event)
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_buf(win) ~= event.buf then
      return
    end
    if vim.bo[event.buf].buftype ~= "" then
      return
    end
    local parser_name = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
    if not parser_name then
      vim.bo[event.buf].syntax = "ON"
      return
    end
    vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo[win].foldmethod = "expr"
  end,
})
