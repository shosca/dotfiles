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
			"nvim-telescope/telescope-ui-select.nvim",
			"nvim-telescope/telescope-cheat.nvim",
			"nvim-telescope/telescope-dap.nvim",
			"nvim-telescope/telescope-github.nvim",
		},
		config = function()
			local actions = require("telescope.actions")
			local themes = require("telescope.themes")
			local telescope = require("telescope")

			telescope.setup({
				defaults = {
					borderchars = {
						"─",
						"│",
						"─",
						"│",
						"╭",
						"╮",
						"╯",
						"╰",
					},
					color_devicons = true,
					extensions = {
						fzy_native = {
							override_generic_sorter = true,
							override_file_sorter = true,
						},
						["ui-select"] = { themes.get_dropdown({}) },
					},
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
							end,
						},
						vertical = {
							width = 0.9,
							height = 0.95,
							preview_height = 0.5,
						},
						flex = { horizontal = { preview_width = 0.9 } },
					},
					layout_strategy = "horizontal",
					path_display = { shorten = 5 },
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
							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
							["<C-n>"] = actions.cycle_history_next,
							["<C-p>"] = actions.cycle_history_prev,
							["<C-c>"] = actions.close,
							["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
							["<CR>"] = actions.select_default + actions.center,
						},
						n = {
							["<j>"] = actions.move_selection_next,
							["<k>"] = actions.move_selection_previous,
							["<C-n>"] = actions.cycle_history_next,
							["<C-p>"] = actions.cycle_history_prev,
							["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
						},
					},
				},
				pickers = { live_grep = { only_sort_text = true } },
			})
			-- fzy native extension
			telescope.load_extension("cheat")
			telescope.load_extension("dap")
			if vim.fn.executable("gh") == 1 then
				telescope.load_extension("gh")
				telescope.load_extension("octo")
			end

			local nmap = require("sh.keymap").nmap
			nmap({
				"<Leader>ff",
				function()
					require("telescope.builtin").resume()
				end,
				{ silent = true },
			})
			nmap({
				"<Leader>fb",
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
				function()
					require("telescope.builtin").find_files(themes.get_dropdown({
						winblend = 10,
						layout_strategy = "vertical",
						border = true,
						previewer = false,
						shorten_path = false,
					}))
				end,
				{ silent = true },
			})
			nmap({
				"<Leader>ft",
				function()
					require("telescope.builtin").git_files(themes.get_dropdown({
						cwd = vim.fn.expand("%:p:h"),
						winblend = 10,
						border = true,
						previewer = false,
						shorten_path = false,
					}))
				end,
				{ silent = true },
			})
			nmap({
				"<Leader>fg",
				function()
					require("telescope.builtin").live_grep({
						fzf_separator = "|>",
					})
				end,
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
			nmap({
				"<Leader>fa",
				function()
					require("telescope.builtin").lsp_code_actions(themes.get_dropdown({
						winblend = 10,
						border = true,
						previewer = false,
						shorten_path = false,
					}))
				end,
				{ silent = true },
			})
		end,
	})
end

return M
