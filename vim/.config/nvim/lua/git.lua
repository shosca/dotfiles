return {
  configure_packer = function(use)
    use "lewis6991/gitsigns.nvim"
    use "rhysd/committia.vim"
    use "sindrets/diffview.nvim"
    use "ruifm/gitlinker.nvim"
    if vim.fn.executable "gh" == 1 then
      use "pwntester/octo.nvim"
    end
  end
}
