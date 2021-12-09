local M = {}

function M.configure_packer(use)
  use "tjdevries/astronauta.nvim"
  use 'bfredl/nvim-luadev'
  use 'tpope/vim-eunuch'
  use "nathom/filetype.nvim"
  use 'benizi/vim-automkdir'
  use 'sgur/vim-editorconfig'
  use 'voldikss/vim-floaterm'
  use {
    "vim-test/vim-test",
    setup = function()
      vim.g['test#python#runner'] = 'pytest'
      vim.g['test#python#pytest#executable'] = 'docker-compose run --rm pytest -v --disable-warnings'
      vim.g['test#strategy'] = "floaterm"
    end,
    config = function()
      local nmap = vim.keymap.map
      nmap {"<leader>tn", ":TestNearest<CR>", silent = true}
      nmap {"<leader>tf", ":TestFile<CR>", silent = true}
      nmap {"<leader>tt", ":TestSuite<CR>", silent = true}
      nmap {"<leader>tl", ":TestLast<CR>", silent = true}
      nmap {"<leader>tv", ":TestVisit<CR>", silent = true}
      nmap {"<leader>tm", ":make test<CR>", silent = true}
    end
  }
  use {
    "rcarriga/vim-ultest",
    requires = {"vim-test/vim-test"},
    run = ":UpdateRemotePlugins",
    setup = function()
      vim.g.ultest_attach_width = 180
      vim.g.ultest_fail_sign = " "
      vim.g.ultest_max_threads = 4
      vim.g.ultest_output_cols = 120
      vim.g.ultest_pass_sign = " "
      vim.g.ultest_running_sign = " "
      vim.g.ultest_use_pty = 1
      vim.g.ultest_use_pty = 1
      vim.g.ultest_virtual_text = 0
    end,
    config = function()
      local nmap = vim.keymap.map
      nmap {"<leader>tn", ":TestNearest<CR>", silent = true}
      nmap {"<leader>tf", ":TestFile<CR>", silent = true}
      nmap {"<leader>tt", ":TestSuite<CR>", silent = true}
      nmap {"<leader>tl", ":TestLast<CR>", silent = true}
      nmap {"<leader>tv", ":TestVisit<CR>", silent = true}
      nmap {"<leader>tm", ":make test<CR>", silent = true}
      nmap {"<leader>vf", "<Plug>(ultest-run-file)"}
      nmap {"<leader>vn", "<Plug>(ultest-run-nearest)"}
      nmap {"<leader>vj", "<Plug>(ultest-next-fail)"}
      nmap {"<leader>vk", "<Plug>(ultest-prev-fail)"}
      nmap {"<leader>vg", "<Plug>(ultest-output-jump)"}
      nmap {"<leader>vo", "<Plug>(ultest-output-show)"}
      nmap {"<leader>vs", "<Plug>(ultest-summary-toggle)"}
      nmap {"<leader>vS", "<Plug>(ultest-summary-jump)"}
      nmap {"<leader>va", "<Plug>(ultest-attach)"}
      nmap {"<leader>vc", "<Plug>(ultest-stop-nearest)"}
      nmap {"<leader>vx", "<Plug>(ultest-stop-file)"}
      nmap {"<leader>vd", "<Plug>(ultest-debug-nearest)"}
    end
  }
  use {
    'CantoroMC/slimux',
    config = function()
      local map = vim.keymap.map
      local vmap = vim.keymap.vmap
      vim.g.slimux_buffer_filetype = 'slimux'
      map {"<leader>s", ":SlimuxREPLSendLine<CR>"}
      vmap {"<leader>s ", ":SlimuxREPLSendSelection<CR>"}
      map {"<leader>b", ":SlimuxREPLSendBuffer<CR>"}
      map {"<C-l><C-l>", ":SlimuxSendKeysLast<CR>"}
      map {"<C-c><C-c>", ":SlimuxREPLSendLine<CR>"}
      vmap {"<C-c><C-c>", ":SlimuxREPLSendSelection<CR>"}
    end
  }
  use {
    "ThePrimeagen/harpoon",
    config = function()
      local nnoremap = vim.keymap.nnoremap
      require("harpoon").setup {projects = {}}
      nnoremap {"<leader>a", function() require("harpoon.mark").add_file() end}
      nnoremap {"<C-e>", function() require("harpoon.ui").toggle_quick_menu() end}
      nnoremap {"<leader>tc", function() require("harpoon.cmd-ui").toggle_quick_menu() end}
      nnoremap {"<C-h>", function() require("harpoon.ui").nav_file(1) end}
      nnoremap {"<C-t>", function() require("harpoon.ui").nav_file(2) end}
      nnoremap {"<C-n>", function() require("harpoon.ui").nav_file(3) end}
      nnoremap {"<C-s>", function() require("harpoon.ui").nav_file(4) end}
    end
  }
  use {
    "ten3roberts/qf.nvim",
    config = function()
      local nnoremap = vim.keymap.nnoremap
      require('qf').setup {}
      nnoremap {"<leader>ll", function() require("qf").toggle('l', true) end}
      nnoremap {"<leader>cc", function() require("qf").toggle('c', true) end}
      nnoremap {"<leader>j", function() require('qf').below('l') end}
      nnoremap {"<leader>k", function() require('qf').above('l') end}
      nnoremap {"<leader>J", function() require'qf'.below('c') end}
      nnoremap {"<leader>K", function() require'qf'.above('c') end}
      nnoremap {"]q", function() require('qf').below('visible') end}
      nnoremap {"[q", function() require'qf'.above('visible') end}
    end
  }
end
return M
