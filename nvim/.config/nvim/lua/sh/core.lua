local M = {}

function M.setup()
  vim.g.ultest_attach_width = 180
  vim.g.ultest_fail_sign = " "
  vim.g.ultest_max_threads = 4
  vim.g.ultest_output_cols = 120
  vim.g.ultest_pass_sign = " "
  vim.g.ultest_running_sign = " "
  vim.g.ultest_use_pty = 1
  vim.g.ultest_use_pty = 1
  vim.g.ultest_virtual_text = 0
  vim.cmd [[
nmap <silent><leader>tn :TestNearest<CR>
nmap <silent><leader>tf :TestFile<CR>
nmap <silent><leader>tt :TestSuite<CR>
nmap <silent><leader>tl :TestLast<CR>
nmap <silent><leader>tv :TestVisit<CR>
nmap <silent><leader>tm :make test<CR>
nmap <silent><leader>to :!firefox coverage/index.html<CR>
nmap <leader>vf <Plug>(ultest-run-file)
nmap <leader>vn <Plug>(ultest-run-nearest)
nmap <leader>vj <Plug>(ultest-next-fail)
nmap <leader>vk <Plug>(ultest-prev-fail)
nmap <leader>vg <Plug>(ultest-output-jump)
nmap <leader>vo <Plug>(ultest-output-show)
nmap <leader>vs <Plug>(ultest-summary-toggle)
nmap <leader>vS <Plug>(ultest-summary-jump)
nmap <leader>va <Plug>(ultest-attach)
nmap <leader>vc <Plug>(ultest-stop-nearest)
nmap <leader>vx <Plug>(ultest-stop-file)
nmap <leader>vd <Plug>(ultest-debug-nearest)
    ]]
end

function M.configure_packer(use)
  use 'lewis6991/impatient.nvim'
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
      vim.cmd [[
nmap <silent><leader>tn :TestNearest<CR>
nmap <silent><leader>tf :TestFile<CR>
nmap <silent><leader>tt :TestSuite<CR>
nmap <silent><leader>tl :TestLast<CR>
nmap <silent><leader>tv :TestVisit<CR>
nmap <silent><leader>tm :make test<CR>
nmap <silent><leader>to :!firefox coverage/index.html<CR>
          ]]
    end
  }
  use {"rcarriga/vim-ultest", requires = {"vim-test/vim-test"}, run = ":UpdateRemotePlugins", setup = M.setup}
  use {
    'CantoroMC/slimux',
    setup = function()
      vim.g.slimux_buffer_filetype = 'slimux'
      vim.cmd [[
map <Leader>s :SlimuxREPLSendLine<CR>
vmap <Leader>s :SlimuxREPLSendSelection<CR>
map <Leader>b :SlimuxREPLSendBuffer<CR>
map <Leader>k :SlimuxSendKeysLast<CR>
map <C-c><C-c> :SlimuxREPLSendLine<CR>
vmap <C-c><C-c> :SlimuxREPLSendSelection<CR>
      ]]
    end
  }
end
return M
