return {
  "jose-elias-alvarez/null-ls.nvim",
  config = function()
    local nullls = require("null-ls")
    nullls.setup({
      debounce = 600,
      sources = {
        nullls.builtins.code_actions.cspell,
        nullls.builtins.code_actions.gitrebase,
        nullls.builtins.code_actions.gitsigns,

        nullls.builtins.formatting.shfmt.with({
          extra_args = {
            "-i",
            "4", -- 4 spaces
            "-ci", -- indent switch cases
            "-sr", -- redirect operators are followed by space
            "-bn", -- binary ops like && or | (pipe) start the line
          },
        }),

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
