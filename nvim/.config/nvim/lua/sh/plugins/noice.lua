local utils = require "sh.utils"

return {
  "folke/noice.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "stevearc/dressing.nvim",
      init = function()
        vim.ui.select = function(...)
          require("lazy").load { plugins = { "dressing.nvim" } }
          return vim.ui.select(...)
        end
        vim.ui.input = function(...)
          require("lazy").load { plugins = { "dressing.nvim" } }
          return vim.ui.input(...)
        end
      end,
    },
  },
  config = function()
    require("noice").setup {
      lsp = {
        hover = {
          silent = true,
        },
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          view = "mini",
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
        },
        {
          view = "notify",
          filter = {
            event = "msg_showmode",
          },
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
    }
    utils.require("telescope", function(m)
      m.load_extension "noice"
    end)
  end,
}
