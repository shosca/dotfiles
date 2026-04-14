return {
  cmd = { "pylsp", "-v", "--log-file", vim.fs.joinpath(vim.fn.stdpath("state"), "pylsp.log") },
  flags = { debounce_text_changes = 300 },
  settings = {
    pylsp = {
      plugins = {
        folding = { enabled = false },
        jedi_completion = { enabled = false },
        jedi_definition = { enabled = false },
        jedi_highlight = { enabled = false },
        jedi_hover = { enabled = false },
        jedi_references = { enabled = false },
        jedi_rename = { enabled = false },
        jedi_signature_help = { enabled = false },
        jedi_symbols = { enabled = false },
        jedi_type_definition = { enabled = false },
        preload = { enabled = false },
        pylint = { enabled = false },
        ruff = { enabled = false },
        flake8 = { enabled = false },
        black = { enabled = false },
        rope_autoimport = { enabled = false },
        rope_completion = { enabled = false },
        pylsp_mypy = {
          enabled = true,
          live_mode = true,
          dmypy = false,
          report_progress = true,
        },
      },
    },
  },
}
