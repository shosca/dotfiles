return {
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
}
