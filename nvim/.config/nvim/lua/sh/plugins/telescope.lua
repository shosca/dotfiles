return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/popup.nvim",
    "nvim-lua/plenary.nvim",
  },
  keys = {
    {
      "<Leader>ff",
      function()
        require("telescope.builtin").resume()
      end,
      silent = true,
    },
    {
      "<Tab>",
      function()
        require("telescope.builtin").buffers({
          shorten_path = false,
          preview = false,
        })
      end,
      silent = true,
    },
    {
      "<Leader>fp",
      function()
        require("telescope.builtin").find_files()
      end,
      { silent = true },
    },
    {
      "<Leader>ft",
      function()
        require("telescope.builtin").git_files()
      end,
      { silent = true },
    },
    {
      "<Leader>fg",
      function()
        require("telescope.builtin").grep_string()
      end,
      { silent = true },
    },
    {
      "<Leader>fd",
      function()
        require("telescope.builtin").fd()
      end,
      { silent = true },
    },
    {
      "<Leader>fw",
      function()
        require("telescope.builtin").find_files({
          cwd = vim.fn.stdpath("data") .. "/site/pack/packer/start/",
        })
      end,
      { silent = true },
    },
  },
  config = function()
    local actions = require("telescope.actions")
    local telescope = require("telescope")
    local ui = require("sh.ui")

    telescope.setup({
      defaults = {
        preview = {
          treesitter = false,
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },
        borderchars = ui.borderchars,
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "bottom",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        file_sorter = require("telescope.sorters").get_fuzzy_file,
        file_ignore_patterns = { "node_modules" },
        generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
        path_display = { "truncate" },
        winblend = 0,
        color_devicons = true,
        use_less = true,
        --file_sorter = require("telescope.sorters").get_fzy_sorter,
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
        mappings = {
          i = {
            ["<Tab>"] = actions.move_selection_next,
            ["<S-Tab>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-c>"] = actions.close,
            ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            ["<CR>"] = actions.select_default + actions.center,
          },
          n = {
            ["q"] = actions.close,
            ["<j>"] = actions.move_selection_next,
            ["<k>"] = actions.move_selection_previous,
            ["<C-n>"] = actions.cycle_history_next,
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
          },
        },
      },
      extensions = {
        fzy_native = {
          override_generic_sorter = false,
          override_file_sorter = true,
        },
      },
    })
  end,
}
