return {
  "jose-elias-alvarez/nvim-lsp-ts-utils",
  config = function()
    require("nvim-lsp-ts-utils").setup({
      auto_inlay_hints = false,
    })
  end,
}
