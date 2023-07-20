return {
  "mfussenegger/nvim-lint",
  config = function()
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
    local lint = require("lint")
    lint.linters_by_ft = {
      python = { "mypy", "flake8" },
    }
  end,
}
