local M = {}

function M.configure_packer(use)
  use("bfredl/nvim-luadev")
  use("tpope/vim-eunuch")
  use("benizi/vim-automkdir")
  use("editorconfig/editorconfig-vim")
  use("vladdoster/remember.nvim")
  use({
    "stevearc/qf_helper.nvim",
    config = function()
      return require("qf_helper").setup({
        prefer_loclist = true, -- Used for QNext/QPrev (see Commands below)
        sort_lsp_diagnostics = true, -- Sort LSP diagnostic results
        quickfix = {
          autoclose = true, -- Autoclose qf if it's the only open window
          default_bindings = true, -- Set up recommended bindings in qf window
          default_options = true, -- Set recommended buffer and window options
          max_height = 10, -- Max qf height when using open() or toggle()
          min_height = 1, -- Min qf height when using open() or toggle()
          track_location = "cursor", -- Keep qf updated with your current location
          -- Use `true` to update position as well
        },
        loclist = { -- The same options, but for the loclist
          autoclose = true,
          default_bindings = true,
          default_options = true,
          max_height = 10,
          min_height = 1,
          track_location = "cursor",
        },
      })
    end,
  })
  use("voldikss/vim-floaterm")
  use({
    "CantoroMC/slimux",
    config = function()
      local nmap = require("sh.keymap").nmap
      local vmap = require("sh.keymap").vmap
      vim.g.slimux_buffer_filetype = "slimux"
      nmap({ "<leader>s", ":SlimuxREPLSendLine<CR>" })
      vmap({ "<leader>s ", ":SlimuxREPLSendSelection<CR>" })
      nmap({ "<leader>b", ":SlimuxREPLSendBuffer<CR>" })
      nmap({ "<C-l><C-l>", ":SlimuxSendKeysLast<CR>" })
      nmap({ "<C-c><C-c>", ":SlimuxREPLSendLine<CR>" })
      vmap({ "<C-c><C-c>", ":SlimuxREPLSendSelection<CR>" })
    end,
  })
  use({
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup({})
    end,
  })
end

return M
