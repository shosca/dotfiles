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
