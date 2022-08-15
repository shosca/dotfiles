vim.o.exrc = false

local M = {}

function M.configure_packer(use)
  use({
    "MunifTanjim/exrc.nvim",
    config = function()
      require("exrc").setup({
        files = {
          ".nvimrc.lua",
          ".nvimrc",
          ".exrc.lua",
          ".exrc",
        },
      })
    end,
  })
  use("bfredl/nvim-luadev")
  use("lambdalisue/suda.vim")
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
  use({
    "nvim-neotest/neotest",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
    },
    config = function()
      local nmap = require("sh.keymap").nmap
      local neotest = require("neotest")
      nmap({ "<leader>tt", neotest.run.run })
      nmap({
        "<leader>tf",
        function()
          neotest.run.run(vim.fn.expand("%"))
        end,
      })
      nmap({ "<leader>to", neotest.output.open })
    end,
  })
  use("nvim-neotest/neotest-python")
end

return M
