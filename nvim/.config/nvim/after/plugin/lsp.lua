local ui = require("sh.ui")

vim.lsp.handlers["textDocument/definition"] = function(_, result)
  if not result or vim.tbl_isempty(result) then
    vim.notify("[LSP] Could not find definition")
    return
  end

  if vim.tbl_islist(result) then
    vim.lsp.util.jump_to_location(result[1], "utf-8", true)
  else
    vim.lsp.util.jump_to_location(result, "utf-8", true)
  end
end
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = ui.borders })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = ui.borders })

vim.api.nvim_create_autocmd("CursorHold", {
  pattern = { "*" },
  callback = function()
    if not require("cmp").visible() then
      local hover_fixed = function()
        local h_util = require("pretty_hover.util")
        local client = h_util.get_current_active_clent()
        if not client then
          return
        end
        vim.api.nvim_command("set eventignore=CursorHold")
        vim.api.nvim_command("autocmd CursorMoved ++once set eventignore=\" \" ")
        require("pretty_hover").hover()
      end
      hover_fixed()
    end
  end,
})
