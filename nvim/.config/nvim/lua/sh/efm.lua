local utils = require("sh.utils")

local tools = {
  terraform_fmt = {
    formatCommand = "terraform fmt -",
    formatStdin = true,
  },
  shfmt = {
    formatCommand = "shfmt -i 2 -ci -sr -bn",
    formatStdin = true,
  },
  black = {
    formatCommand = table.concat({ utils.find_venv_command({ cmd = "black" }), "--quiet", "-" }, " "),
    formatStdin = true,
  },
  prettierd = {
    formatCommand = table.concat({
      utils.find_node_command({ cmd = "prettierd" }),
      "${INPUT}",
      "${--range-start=charStart}",
      "${--range-end=charEnd}",
      "${--tab-width=tabSize}",
    }, " "),
    formatStdin = true,
    rootMarkers = {
      ".prettierrc",
      ".prettierrc.json",
      ".prettierrc.js",
      ".prettierrc.yml",
      ".prettierrc.yaml",
      ".prettierrc.json5",
      ".prettierrc.mjs",
      ".prettierrc.cjs",
      ".prettierrc.toml",
    },
  },
  luacheck = {
    lintCommand = table.concat({ "luacheck", "--codes", "--no-color", " --quiet", "-" }, " "),
    lintStdin = true,
    lintFormats = { "%.%#:%l:%c: (%t%n) %m" },
  },
  flake8 = {
    lintCommand = table.concat({
      utils.find_venv_command({ cmd = "flake8" }),
      " --stdin-display-name",
      "${INPUT} -",
    }, " "),
    lintStdin = true,
    lintFormats = {
      "%f:%l:%c: %m",
    },
    lintDebounce = "1s",
  },
  mypy = {
    lintCommand = table.concat({
      utils.find_venv_command({ cmd = "mypy" }),
      "--show-column-numbers",
      "--show-error-codes",
      "--no-color-output",
      "--no-error-summary",
    }, " "),
    lintFormats = {
      "%f:%l:%c: %trror: %m",
      "%f:%l:%c: %tarning: %m",
      "%f:%l:%c: %tote: %m",
    },
    lintDebounce = "1s",
  },
  hadolint = {
    lintCommand = "hadolint --no-color -",
    lintStdin = true,
    lintFormats = { "-:%l %.%# %trror: %m", "-:%l %.%# %tarning: %m", "-:%l %.%# %tnfo: %m" },
  },
}
return {
  lua = {
    tools.luacheck,
  },
  sh = {
    tools.shfmt,
  },
  terraform = {
    tools.terraform_fmt,
  },
  hcl = {
    tools.terraform_fmt,
  },
  python = {
    tools.black,
    -- tools.flake8,
    -- tools.mypy,
  },
  dockerfile = {
    tools.hadolint,
  },
  javascript = {
    tools.prettierd,
  },
  javascriptreact = {
    tools.prettierd,
  },
  typescript = {
    tools.prettierd,
  },
  typescriptreact = {
    tools.prettierd,
  },
}
