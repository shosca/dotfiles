local M = {}

function M.configure_packer(use)
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true,
          use_languagetree = true,
          disable = {}, -- list of language that will be disabled
        },
        rainbow = { enable = true, extended_mode = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
        autopairs = { enable = true },
        indent = { enable = true, disable = { "python" } },
        refactor = {
          highlight_definitions = { enable = true },
          highlight_current_scope = { enable = false },
          smart_rename = {
            enable = true,
            keymaps = { smart_rename = "grr" },
          },
        },
        pyfold = { enable = true, custom_foldtext = true },
        endwise = { enable = true },
      })
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    end,
  })
  use({ "eddiebergman/nvim-treesitter-pyfold" })
  use({ "nvim-treesitter/nvim-treesitter-refactor" })
  use({ "nvim-treesitter/nvim-treesitter-textobjects" })
  use({ "RRethy/nvim-treesitter-endwise" })
end

local installed = {}
local group = vim.api.nvim_create_augroup("TSAutoInstaller", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = group,
  pattern = "*",
  callback = function()
    local parsers = require("nvim-treesitter.parsers")
    local lang = parsers.get_buf_lang()
    local parser_configs = parsers.get_parser_configs()
    if parser_configs[lang] ~= nil and not parsers.has_parser(lang) and installed[lang] ~= false then
      vim.schedule(function()
        vim.ui.input({ prompt = "Install tree-sitter for " .. lang .. "? (Y/n)" }, function(input)
          if input:match("\r") or input:match("y") or input:match("Y") then
            vim.notify("Installing treesitter for " .. lang)
            vim.cmd("TSInstall " .. lang)
            installed[lang] = true
          else
            installed[lang] = false
          end
        end)
      end)
    end
  end,
})

return M
