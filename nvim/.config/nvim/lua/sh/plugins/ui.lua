local M = {
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
      "stevearc/dressing.nvim",
    },
    config = function()
      require("noice").setup()
      local notify = require("notify")
      notify.setup({
        background_colour = "#000000",
      })
      require("telescope").load_extension("notify")
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({ "*" })
    end,
  },
  {
    "marko-cerovac/material.nvim",
    dependencies = {
      "xiyaowong/nvim-transparent",
    },
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
          background = false, -- Prevent the theme from setting the background (NeoVim then uses your teminal background)
          term_colors = false, -- Prevent the theme from setting terminal colors
          eob_lines = false, -- Hide the end-of-buffer lines
        },
        custom_highlights = {}, -- Overwrite highlights with your own
      })
      require("transparent").setup({})
      vim.api.nvim_command("colorscheme material")
    end,
  },
  { "kyazdani42/nvim-web-devicons" },
  {
    "SmiteshP/nvim-gps",
    config = function()
      local kind_icons = require("lspkind").symbol_map
      require("nvim-gps").setup({
        icons = {
          ["class-name"] = kind_icons.Class .. " ",
          ["object-name"] = kind_icons.Variable .. " ",
          ["array-name"] = kind_icons.Struct .. " ",
          ["function-name"] = kind_icons.Function .. " ",
          ["method-name"] = kind_icons.Method .. " ",
          ["container-name"] = kind_icons.Module .. " ",
          ["tag-name"] = kind_icons.Reference .. " ",
        },
        languages = {
          ["c"] = true,
          ["cpp"] = true,
          ["go"] = true,
          ["java"] = true,
          ["javascript"] = true,
          ["lua"] = true,
          ["python"] = true,
          ["rust"] = true,
        },
        separator = " > ",
      })
    end,
  },
  {
    "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup({
        input = {
          prompt_align = "center",
          anchor = "NW",
          max_width = { 140, 0.9 },
          min_width = { 40, 0.6 },
        },
      })
    end,
  },
  {
    "feline-nvim/feline.nvim",
    dependencies = { "marko-cerovac/material.nvim" },
    config = function()
      local colors = require("material.colors")
      local lsp = require("feline.providers.lsp")
      local vi_mode_utils = require("feline.providers.vi_mode")

      local vi_mode_colors = {
        NORMAL = colors.green,
        INSERT = colors.red,
        VISUAL = colors.magenta,
        OP = colors.green,
        BLOCK = colors.blue,
        REPLACE = colors.violet,
        ["V-REPLACE"] = colors.violet,
        ENTER = colors.cyan,
        MORE = colors.cyan,
        SELECT = colors.orange,
        COMMAND = colors.green,
        SHELL = colors.green,
        TERM = colors.green,
        NONE = colors.yellow,
      }

      local icons = {
        linux = " ",
        macos = " ",
        windows = " ",

        error = " ",
        warn = " ",
        info = " ",
        hint = " ",

        lsp = " ",
        git = "",
      }

      local diagnos = {
        of = function(s)
          local icon = icons[string.lower(s)]
          return function()
            local diag = lsp.get_diagnostics_count(s)
            return icon .. diag
          end
        end,
        enable = function(s)
          return function()
            local diag = lsp.get_diagnostics_count(s)
            return diag and diag ~= 0
          end
        end,
      }
      diagnos.err = {
        provider = diagnos.of("Error"),
        left_sep = " ",
        enabled = diagnos.enable("Error"),
        hl = { fg = colors.red },
      }
      diagnos.warn = {
        provider = diagnos.of("Warn"),
        left_sep = " ",
        enabled = diagnos.enable("Warn"),
        hl = { fg = colors.yellow },
      }
      diagnos.info = {
        provider = diagnos.of("Info"),
        left_sep = " ",
        enabled = diagnos.enable("Info"),
        hl = { fg = colors.blue },
      }
      diagnos.hint = {
        provider = diagnos.of("Hint"),
        left_sep = " ",
        enabled = diagnos.enable("Hint"),
        hl = { fg = colors.cyan },
      }

      local vi_mode = {
        hl = function()
          return {
            name = vi_mode_utils.get_mode_highlight_name(),
            fg = vi_mode_utils.get_mode_color(),
          }
        end,
      }
      vi_mode.left = { provider = "▊", hl = vi_mode.hl, right_sep = " " }
      vi_mode.right = { provider = "▊", hl = vi_mode.hl, left_sep = " " }

      local file = {
        info = {
          provider = "file_info",
          hl = { fg = colors.blue, style = "bold" },
        },
        encoding = {
          provider = "file_encoding",
          left_sep = " ",
          hl = { fg = colors.violet, style = "bold" },
        },
        type = { provider = "file_type" },
        os = {
          provider = function()
            local os = vim.bo.fileformat:upper()
            local icon
            if os == "UNIX" then
              icon = icons.linux
            elseif os == "MAC" then
              icon = icons.macos
            else
              icon = icons.windows
            end
            return icon .. os
          end,

          left_sep = " ",
          hl = { fg = colors.violet, style = "bold" },
        },
      }

      local line_percentage = {
        provider = "line_percentage",
        left_sep = " ",
        hl = { style = "bold" },
      }
      local scroll_bar = {
        provider = "scroll_bar",
        left_sep = " ",
        hl = { fg = colors.blue, style = "bold" },
      }

      local lsp_ = {
        provider = "lsp_client_names",
        left_sep = " ",
        icon = icons.lsp,
        hl = { fg = colors.yellow },
      }

      local gps = {
        provider = function()
          return require("nvim-gps").get_location()
        end,
        enabled = function()
          return require("nvim-gps").is_available()
        end,
        left_sep = " ",
        hl = { fg = colors.blue },
      }

      local git = {
        branch = {
          provider = "git_branch",
          icon = icons.git,
          left_sep = " ",
          hl = { fg = colors.violet, style = "bold" },
        },
        add = {
          provider = "git_diff_added",
          hl = { fg = colors.green },
        },
        change = {
          provider = "git_diff_changed",
          hl = { fg = colors.orange },
        },
        remove = {
          provider = "git_diff_removed",
          hl = { fg = colors.red },
        },
      }

      require("feline").setup({
        colors = { bg = colors.bg, fg = colors.fg },
        vi_mode_colors = vi_mode_colors,
        force_inactive = {
          filetypes = {
            "NvimTree",
            "dbui",
            "packer",
            "startify",
            "fugitive",
            "fugitiveblame",
          },
          buftypes = { "terminal" },
          bufnames = {},
        },
        components = {
          active = {
            {
              vi_mode.left,
              gps,
              diagnos.err,
              diagnos.warn,
              diagnos.hint,
              diagnos.info,
            },
            {},
            {
              git.add,
              git.change,
              git.remove,
              lsp_,
              file.os,
              git.branch,
              line_percentage,
              scroll_bar,
              vi_mode.right,
            },
          },
          inactive = { { vi_mode.left }, {} },
        },
      })
      require("feline").winbar.setup({
        components = {
          active = {
            {},
            {},
            {
              file.info,
            },
          },
          inactive = {
            {},
            {},
            {
              file.info,
            },
          },
        },
      })
    end,
  },
  {
    "goolord/alpha-nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    config = function()
      require("alpha").setup(require("alpha.themes.startify").config)
      require("alpha").start(true)
    end,
  },
  {
    "anuvyklack/windows.nvim",
    dependencies = {
      "anuvyklack/middleclass",
      "anuvyklack/animation.nvim",
    },
    config = function()
      vim.o.winwidth = 20
      vim.o.winminwidth = 20
      vim.o.equalalways = false
      require("windows").setup()
    end,
  },
}

return M
