return {
  { "echasnovski/mini.align", opts = {} },
  { "echasnovski/mini.basics", opts = {} },
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>bd",
        function()
          require("mini.bufremove").delete(0, false)
        end,
        desc = "Delete Buffer",
      },
      {
        "<leader>bD",
        function()
          require("mini.bufremove").delete(0, true)
        end,
        desc = "Delete Buffer (Force)",
      },
    },
  },
  { "echasnovski/mini.comment", opts = {} },
  { "echasnovski/mini.indentscope", opts = {} },
  { "echasnovski/mini.move", opts = {} },
  { "echasnovski/mini.operators", opts = {} },
  { "echasnovski/mini.pairs", opts = {} },
  -- { "echasnovski/mini.starter",     opts = {}, },
  {
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = "gza", -- Add surrounding in Normal and Visual modes
        delete = "gzd", -- Delete surrounding
        find = "gzf", -- Find surrounding (to the right)
        find_left = "gzF", -- Find surrounding (to the left)
        highlight = "gzh", -- Highlight surrounding
        replace = "gzr", -- Replace surrounding
        update_n_lines = "gzn", -- Update `n_lines`
      },
    },
  },
  { "echasnovski/mini.trailspace", opts = {} },
}
