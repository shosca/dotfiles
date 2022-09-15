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
        endwise = { enable = true },
      })
    end,
  })
  use({ "nvim-treesitter/nvim-treesitter-refactor" })
  use({ "nvim-treesitter/nvim-treesitter-textobjects" })
  use({ "RRethy/nvim-treesitter-endwise" })
end

local asking = {}
local group = vim.api.nvim_create_augroup("TSAutoInstaller", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  group = group,
  --once = true,
  pattern = "*",
  callback = function()
    local parsers = require("nvim-treesitter.parsers")
    local lang = parsers.get_buf_lang()
    local parser_configs = parsers.get_parser_configs()
    if asking[lang] ~= nil then
      return
    end
    asking[lang] = true
    if parser_configs[lang] == nil then
      return
    end
    if parsers.has_parser(lang) then
      return
    end
    vim.defer_fn(function()
      vim.ui.input({ prompt = "Install tree-sitter for " .. lang .. "? (Y/n)" }, function(input)
        if input:match("y") or input:match("Y") then
          vim.cmd("TSInstall " .. lang)
          vim.cmd("TSEnable " .. lang)
        end
      end)
    end, 1000)
  end,
})

return M
