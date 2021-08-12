local M = {}

local function config()
  vim.api.nvim_set_keymap("n", "<Leader>b", ":Telescope buffers<CR>", {noremap = true, silent = true})
  vim.api.nvim_set_keymap("n", "<Leader>f", ":Telescope find_files<CR>", {noremap = true, silent = true})
  vim.api.nvim_set_keymap("n", "<Leader>g", ":Telescope live_grep<CR>", {noremap = true, silent = true})
  vim.api.nvim_set_keymap("n", "<Leader>dd", ":Telescope lsp_document_diagnostics<CR>", {noremap = true, silent = true})
  vim.api.nvim_set_keymap("n", "<Leader>wd", ":Telescope lsp_workspace_diagnostics<CR>", {noremap = true, silent = true})

  local actions = require('telescope.actions')
  require('telescope').setup {
    defaults = {
      borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
      color_devicons = true,
      extensions = {fzy_native = {override_generic_sorter = true, override_file_sorter = true}},
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      initial_mode = "insert",
      layout_config = {
        width = 0.95,
        height = 0.85,
        prompt_position = "top",
        horizontal = {
          preview_width = function(_, cols, _)
            if cols > 200 then
              return math.floor(cols * 0.4)
            else
              return math.floor(cols * 0.6)
            end
          end
        },
        vertical = {width = 0.9, height = 0.95, preview_height = 0.5},
        flex = {horizontal = {preview_width = 0.9}}
      },
      layout_strategy = "horizontal",
      path_display = {shorten = 5},
      prompt_prefix = "❯ ",
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      scroll_strategy = "cycle",
      selection_caret = "❯ ",
      selection_strategy = "reset",
      sorting_strategy = "descending",
      use_less = true,
      winblend = 0,
      mappings = {
        i = {
          ["<C-n>"] = actions.move_selection_next,
          ["<C-p>"] = actions.move_selection_previous,
          ["<C-c>"] = actions.close,
          ["<C-j>"] = actions.cycle_history_next,
          ["<C-k>"] = actions.cycle_history_prev,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
          ["<CR>"] = actions.select_default + actions.center
        },
        n = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist
        }
      }
    }
  }
  -- fzy native extension
  pcall(require("telescope").load_extension, "cheat")
  pcall(require("telescope").load_extension, "dap")
  pcall(require("telescope").load_extension, "arecibo")
  pcall(require("telescope").load_extension, "flutter")
  if vim.fn.executable "gh" == 1 then
    pcall(require("telescope").load_extension, "gh")
    pcall(require("telescope").load_extension, "octo")
  end
end

function M.configure_packer(use)
  use 'nvim-telescope/telescope-fzy-native.nvim'
  use {'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}, config = config}
end
return M
