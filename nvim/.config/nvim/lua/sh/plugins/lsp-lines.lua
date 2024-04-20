local enable = true
return {
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  opts = {},
  keys = {
    {
      "<Leader>dd",
      function()
        enable = not enable
        vim.diagnostic.config({ virtual_lines = enable })
      end,
      desc = "Toggle [d]iagnostics",
    },
  },
}
