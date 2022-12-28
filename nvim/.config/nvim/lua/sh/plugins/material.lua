return {
  "marko-cerovac/material.nvim",
  config = function()
    require("material").setup({
      contrast = {
        -- Enable contrast for sidebars, floating windows and popup menus like Nvim-Tree
        sidebars = true,
        floating_windows = true,
        popup_menu = true,
      },
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = { italic = true },
      },
      high_visibility = {
        lighter = false, -- Enable higher contrast text for lighter style
        darker = false, -- Enable higher contrast text for darker style
      },
      disable = {
        background = true, -- Prevent the theme from setting the background (NeoVim then uses your teminal background)
        term_colors = false, -- Prevent the theme from setting terminal colors
        eob_lines = false, -- Hide the end-of-buffer lines
      },
      custom_highlights = {}, -- Overwrite highlights with your own
    })
    vim.api.nvim_command("colorscheme material")
  end,
}
