local M = {}

function M.configure_packer(use)
  use {
    'marko-cerovac/material.nvim',
    setup = function()
      vim.opt.termguicolors = true
      vim.opt.background = 'dark'

      vim.g.material_style = 'deep ocean'
      vim.g.material_italic_comments = true
      vim.g.material_italic_keywords = true
      vim.g.material_italic_functions = true
      vim.g.material_italic_variables = false
      vim.g.material_contrast = true
      vim.g.material_borders = false
      vim.g.material_disable_background = false
    end,
    config = function() require('material').set() end
  }

  use {"kyazdani42/nvim-web-devicons"}
  use {
    -- 'hoob3rt/lualine.nvim', https://github.com/hoob3rt/lualine.nvim/issues/230
    -- commit = 'dc2c711a5329470a64f07da100113e598044c5ae',

    'shadmansaleh/lualine.nvim',
    requires = {{'kyazdani42/nvim-web-devicons'}, {'marko-cerovac/material.nvim'}},
    config = function()
      require('lualine').setup {
        options = {
          theme = 'material-nvim',
          icons_enabled = true,
          component_separators = {'', ''},
          section_separators = {'', ''},
          disabled_filetypes = {}
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch'},
          lualine_c = {'filename', 'data', require'lsp-status'.status},
          lualine_x = {{'diagnostics', sources = {'nvim_lsp'}}, 'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {lualine_a = {}, lualine_b = {}, lualine_c = {'filename'}, lualine_x = {'location'}, lualine_y = {}, lualine_z = {}},
        tabline = {},
        extensions = {}
      }
    end
  }
  use {
    'kdheepak/tabline.nvim',
    config = function()
      require('tabline').setup()
      vim.cmd [[
                set guioptions-=e
                set sessionoptions+=tabpages,globals " store tabpages and globals in session
            ]]
    end
  }
  use {'folke/trouble.nvim', requires = 'kyazdani42/nvim-web-devicons', config = function() require('trouble').setup {} end}
end
return M
