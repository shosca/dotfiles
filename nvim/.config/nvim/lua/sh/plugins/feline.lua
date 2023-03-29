return {
  "freddiehaddad/feline.nvim",
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
        return require("nvim-navic").get_location()
      end,
      enabled = function()
        return require("nvim-navic").is_available()
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
}
