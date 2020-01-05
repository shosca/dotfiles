let g:firenvim_config = {
  \ 'globalSettings': {
    \ 'alt': 'all',
  \  },
  \ 'localSettings': {
    \ '.*': {
        \ 'cmdline': 'neovim',
        \ 'priority': 0,
        \ 'selector': 'textarea',
        \ 'takeover': 'never',
    \ },
  \ }
\ }

au BufEnter github.com_*.txt set filetype=markdown
au BufEnter www.reddit.com_*.txt set filetype=markdown
