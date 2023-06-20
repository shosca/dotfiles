return {
  "jose-elias-alvarez/null-ls.nvim",
  dependencies = {
    "ThePrimeagen/refactoring.nvim",
  },
  config = function()
    local nullls = require("null-ls")
    nullls.setup({
      debounce = 600,
      sources = {
        nullls.builtins.code_actions.cspell,
        nullls.builtins.code_actions.gitrebase,
        nullls.builtins.code_actions.gitsigns,
        nullls.builtins.code_actions.refactoring,

        nullls.builtins.formatting.stylua,
        nullls.builtins.formatting.shfmt.with({
          extra_args = {
            "-i",
            "2", -- 4 spaces
            "-ci", -- indent switch cases
            "-sr", -- redirect operators are followed by space
            "-bn", -- binary ops like && or | (pipe) start the line
          },
        }),

        nullls.builtins.diagnostics.buf,
        nullls.builtins.diagnostics.eslint,
        nullls.builtins.diagnostics.flake8.with({
          dynamic_command = function(params)
            return require("sh.utils").find_venv_command(params.root, params.command)
          end,
        }),
        nullls.builtins.formatting.black.with({
          dynamic_command = function(params)
            return require("sh.utils").find_venv_command(params.root, params.command)
          end,
        }),
        nullls.builtins.formatting.terraform_fmt.with({
          filetypes = { "hcl", "terraform" },
        }),
      },
    })
  end,
}
