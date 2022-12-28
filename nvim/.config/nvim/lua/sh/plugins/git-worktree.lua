return {
  "ThePrimeagen/git-worktree.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    {
      "<Leader>gw",
      function()
        require("telescope").extensions.git_worktree.git_worktrees()
      end,
    },
    {
      "<Leader>gm",
      function()
        require("telescope").extensions.git_worktree.create_git_worktree()
      end,
    },
  },
}
