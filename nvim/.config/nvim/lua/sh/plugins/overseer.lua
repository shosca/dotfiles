return {
  "stevearc/overseer.nvim",
  config = function()
    require("overseer").setup()
    vim.keymap.set("n", "<F1>", ":OverseerToggle<cr>", { silent = true })
  end,
}
