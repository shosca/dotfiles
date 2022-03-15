local M = {}

function M.configure_packer(use)
  use 'bfredl/nvim-luadev'
  use 'tpope/vim-eunuch'
  use 'benizi/vim-automkdir'
  use 'sgur/vim-editorconfig'
  use 'voldikss/vim-floaterm'
  use {
    'CantoroMC/slimux',
    config = function()
      local nmap = require("sh.keymap").nmap
      local vmap = require("sh.keymap").vmap
      vim.g.slimux_buffer_filetype = 'slimux'
      nmap {"<leader>s", ":SlimuxREPLSendLine<CR>"}
      vmap {"<leader>s ", ":SlimuxREPLSendSelection<CR>"}
      nmap {"<leader>b", ":SlimuxREPLSendBuffer<CR>"}
      nmap {"<C-l><C-l>", ":SlimuxSendKeysLast<CR>"}
      nmap {"<C-c><C-c>", ":SlimuxREPLSendLine<CR>"}
      vmap {"<C-c><C-c>", ":SlimuxREPLSendSelection<CR>"}
    end
  }
  use {
    "ThePrimeagen/harpoon",
    config = function()
      local nmap = require("sh.keymap").nmap
      require("harpoon").setup {projects = {}}
      nmap {"<leader>a", function() require("harpoon.mark").add_file() end}
      nmap {"<C-e>", function() require("harpoon.ui").toggle_quick_menu() end}
      nmap {"<leader>tc", function() require("harpoon.cmd-ui").toggle_quick_menu() end}
      nmap {"<C-h>", function() require("harpoon.ui").nav_file(1) end}
      nmap {"<C-t>", function() require("harpoon.ui").nav_file(2) end}
      nmap {"<C-n>", function() require("harpoon.ui").nav_file(3) end}
      nmap {"<C-s>", function() require("harpoon.ui").nav_file(4) end}
    end
  }
end
return M
