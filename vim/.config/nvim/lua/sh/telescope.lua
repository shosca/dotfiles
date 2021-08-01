local M = {}

local function config()
    vim.api.nvim_set_keymap("n", "<Leader>b", ":Telescope buffers<CR>",
                            {noremap = true, silent = true})
    vim.api.nvim_set_keymap("n", "<Leader>f", ":Telescope find_files<CR>",
                            {noremap = true, silent = true})
    vim.api.nvim_set_keymap("n", "<Leader>g", ":Telescope live_grep<CR>",
                            {noremap = true, silent = true})
    require('telescope').setup {
        defaults = {
            prompt_prefix = "❯ ",
            selection_caret = "❯ ",
            winblend = 0,
            borderchars = {
                "─", "│", "─", "│", "╭", "╮", "╯", "╰"
            },
            layout_strategy = "horizontal",
            layout_config = {
                width = 0.95,
                height = 0.85,
                -- preview_cutoff = 120,
                prompt_position = "top",
                horizontal = {
                    -- width_padding = 0.1,
                    -- height_padding = 0.1,
                    preview_width = function(_, cols, _)
                        if cols > 200 then
                            return math.floor(cols * 0.4)
                        else
                            return math.floor(cols * 0.6)
                        end
                    end
                },
                vertical = {
                    -- width_padding = 0.05,
                    -- height_padding = 1,
                    width = 0.9,
                    height = 0.95,
                    preview_height = 0.5
                },

                flex = {horizontal = {preview_width = 0.9}}
            },
            selection_strategy = "reset",
            sorting_strategy = "descending",
            scroll_strategy = "cycle",
            color_devicons = true,
            file_previewer = require("telescope.previewers").vim_buffer_cat.new,
            grep_previewer = require("telescope.previewers").vim_buffer_vimgrep
                .new,
            qflist_previewer = require("telescope.previewers").vim_buffer_qflist
                .new,
            extensions = {
                fzy_native = {
                    override_generic_sorter = true,
                    override_file_sorter = true
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
    use {
        'nvim-telescope/telescope.nvim',
        requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
        config = config
    }
end
return M
