local M = {}

function M.configure_packer(use)
  use("nvim-telescope/telescope-fzy-native.nvim")
  use({
    "ThePrimeagen/git-worktree.nvim",
    config = function()
      local nmap = require("sh.keymap").nmap
      nmap({
        "<Leader>gw",
        require("telescope").extensions.git_worktree.git_worktrees,
      })
      nmap({
        "<Leader>gm",
        require("telescope").extensions.git_worktree.create_git_worktree,
      })
    end,
  })
  use({
    "pwntester/octo.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "kyazdani42/nvim-web-devicons",
    },
    config = function()
      require("octo").setup()
    end,
  })
  use({
    "nvim-telescope/telescope.nvim",
    requires = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
    },
    config = function()
      local actions = require("telescope.actions")
      local telescope = require("telescope")
      local ui = require("sh.ui")

      telescope.setup({
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
          },
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
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
          border = {},
          borderchars = ui.borderchars,
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

      local nmap = require("sh.keymap").nmap
      nmap({
        "<Leader>ff",
        require("telescope.builtin").resume,
        { silent = true },
      })
      nmap({
        "<Tab>",
        function()
          require("telescope.builtin").buffers({
            shorten_path = false,
            preview = false,
          })
        end,
        { silent = true },
      })
      nmap({
        "<Leader>fp",
        require("telescope.builtin").find_files,
        { silent = true },
      })
      nmap({
        "<Leader>ft",
        require("telescope.builtin").git_files,
        { silent = true },
      })
      nmap({
        "<Leader>fg",
        require("telescope.builtin").grep_string,
        { silent = true },
      })
      nmap({
        "<Leader>fd",
        function()
          require("telescope.builtin").fd()
        end,
        { silent = true },
      })
      nmap({
        "<Leader>fw",
        function()
          require("telescope.builtin").find_files({
            cwd = vim.fn.stdpath("data") .. "/site/pack/packer/start/",
          })
        end,
        { silent = true },
      })
    end,
  })
  use({
    "nvim-telescope/telescope-cheat.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("cheat")
    end,
  })
  use({
    "nvim-telescope/telescope-dap.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("dap")
    end,
  })
  use({
    "nvim-telescope/telescope-github.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("gh")
    end,
  })
  use({
    "nvim-telescope/telescope-packer.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("packer")
    end,
  })
  use({
    "nvim-telescope/telescope-symbols.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
  })
  use({
    "nvim-telescope/telescope-project.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("project")
    end,
  })
  use({
    "nvim-telescope/telescope-fzy-native.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension("fzy_native")
    end,
  })
end

return M
