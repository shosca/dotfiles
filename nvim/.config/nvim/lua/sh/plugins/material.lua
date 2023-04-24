-- return {
--   "marko-cerovac/material.nvim",
--   config = function()
--     require("material").setup({
--       contrast = {
--         -- Enable contrast for sidebars, floating windows and popup menus like Nvim-Tree
--         sidebars = true,
--         floating_windows = true,
--         popup_menu = true,
--       },
--       styles = {
--         comments = { italic = true },
--         keywords = { italic = true },
--         functions = { italic = true },
--       },
--       high_visibility = {
--         lighter = false, -- Enable higher contrast text for lighter style
--         darker = false, -- Enable higher contrast text for darker style
--       },
--       disable = {
--         background = true, -- Prevent the theme from setting the background (NeoVim then uses your teminal background)
--         term_colors = false, -- Prevent the theme from setting terminal colors
--         eob_lines = false, -- Hide the end-of-buffer lines
--       },
--       custom_highlights = {}, -- Overwrite highlights with your own
--     })
--     vim.api.nvim_command("colorscheme material")
--   end,
-- }
return {
  "folke/tokyonight.nvim",
  config = function()
    require("tokyonight").setup({
      stype = "night",
      transparent = true,
      styles = {
        -- Style to be applied to different syntax groups
        -- Value is any valid attr-list value for `:help nvim_set_hl`
        comments = { italic = true },
        keywords = { italic = true },
        functions = { italic = true },
        variables = {},
        -- Background styles. Can be "dark", "transparent" or "normal"
        sidebars = "dark", -- style for sidebars, see below
        floats = "dark", -- style for floating windows
      },
      on_highlights = function(hl, c)
        local prompt = "#2d3149"
        hl.TelescopeNormal = {
          bg = c.bg_dark,
          fg = c.fg_dark,
        }
        hl.TelescopeBorder = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
        hl.TelescopePromptNormal = {
          bg = prompt,
        }
        hl.TelescopePromptBorder = {
          bg = prompt,
          fg = prompt,
        }
        hl.TelescopePromptTitle = {
          bg = prompt,
          fg = prompt,
        }
        hl.TelescopePreviewTitle = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
        hl.TelescopeResultsTitle = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
      end,
    })
    vim.cmd([[colorscheme tokyonight-night]])
  end,
}
