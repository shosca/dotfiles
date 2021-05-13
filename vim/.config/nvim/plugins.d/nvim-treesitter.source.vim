lua <<EOF
require "nvim-treesitter.configs".setup {
  ensure_installed = "all",
  highlight = {
    enable = true,
    disable = {  },  -- list of language that will be disabled
  },
  rainbow = {
    enable = true,
    extended_mode = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true,
  }
}
EOF

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
