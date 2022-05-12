vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.g.material_style = "deep ocean"
vim.g.transparent_enabled = true
vim.opt.laststatus = 3
vim.cmd([[colorscheme material]])

local borders = {
  bottom_left = "╰",
  bottom_right = "╯",
  line_horizontal = "─",
  line_vertical = "│",
  top_left = "╭",
  top_right = "╮",
}

local M = {
  borders = {
    borders.top_left,
    borders.line_horizontal,
    borders.top_right,
    borders.line_vertical,
    borders.bottom_right,
    borders.line_horizontal,
    borders.bottom_left,
    borders.line_vertical,
  },
  borderchars = {
    borders.line_horizontal,
    borders.line_vertical,
    borders.line_horizontal,
    borders.line_vertical,
    borders.top_left,
    borders.top_right,
    borders.bottom_left,
    borders.bottom_right,
  },
}

function M.make_borders(hl_name)
  return {
    { borders.top_left, hl_name },
    { borders.line_horizontal, hl_name },
    { borders.top_right, hl_name },
    { borders.line_vertical, hl_name },
    { borders.bottom_right, hl_name },
    { borders.line_horizontal, hl_name },
    { borders.bottom_left, hl_name },
    { borders.line_vertical, hl_name },
  }
end

function M.configure_packer(use)
  use({
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
    end,
  })
  use({
    "marko-cerovac/material.nvim",
    requires = {
      "xiyaowong/nvim-transparent",
    },
    config = function()
      vim.cmd([[colorscheme material]])
      require("material").setup({
        contrast = {
          -- Enable contrast for sidebars, floating windows and popup menus like Nvim-Tree
          sidebars = true,
          floating_windows = true,
          line_numbers = false,
          sign_column = false,
          cursor_line = false,
          non_current_windows = false,
          popup_menu = true,
        },
        italics = {
          comments = true,
          keywords = true,
          functions = true,
          strings = false,
          variables = false,
        },
        contrast_windows = { -- Specify which windows get the contrasted (darker) background
          "terminal", -- Darker terminal background
          "packer", -- Darker packer background
          "qf", -- Darker qf list background
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
    end,
  })
  use({ "kyazdani42/nvim-web-devicons" })
  use({
    "SmiteshP/nvim-gps",
    config = function()
      local kind_icons = require("lspkind").presets.default
      require("nvim-gps").setup({
        icons = {
          ["class-name"] = kind_icons.Class .. " ",
          ["function-name"] = kind_icons.Function .. " ",
          ["method-name"] = kind_icons.Method .. " ",
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
  })
  use({
    "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup({})
    end,
  })
  use({
    "feline-nvim/feline.nvim",
    requires = { "marko-cerovac/material.nvim" },
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

        errs = " ",
        warns = " ",
        infos = " ",
        hints = " ",

        lsp = " ",
        git = "",
      }

      local function file_osinfo()
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
      end

      local function lsp_diagnostics_info()
        return {
          errs = lsp.get_diagnostics_count("Error"),
          warns = lsp.get_diagnostics_count("Warn"),
          infos = lsp.get_diagnostics_count("Info"),
          hints = lsp.get_diagnostics_count("Hint"),
        }
      end

      local function diag_enable(f, s)
        return function()
          local diag = f()[s]
          return diag and diag ~= 0
        end
      end

      local function diag_of(f, s)
        local icon = icons[s]
        return function()
          local diag = f()[s]
          return icon .. diag
        end
      end

      local function vimode_hl()
        return {
          name = vi_mode_utils.get_mode_highlight_name(),
          fg = vi_mode_utils.get_mode_color(),
        }
      end

      local comps = {
        vi_mode = {
          left = { provider = "▊", hl = vimode_hl, right_sep = " " },
          right = { provider = "▊", hl = vimode_hl, left_sep = " " },
        },
        file = {
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
            provider = file_osinfo,
            left_sep = " ",
            hl = { fg = colors.violet, style = "bold" },
          },
        },
        line_percentage = {
          provider = "line_percentage",
          left_sep = " ",
          hl = { style = "bold" },
        },
        scroll_bar = {
          provider = "scroll_bar",
          left_sep = " ",
          hl = { fg = colors.blue, style = "bold" },
        },
        diagnos = {
          err = {
            provider = diag_of(lsp_diagnostics_info, "errs"),
            left_sep = " ",
            enabled = diag_enable(lsp_diagnostics_info, "errs"),
            hl = { fg = colors.red },
          },
          warn = {
            provider = diag_of(lsp_diagnostics_info, "warns"),
            left_sep = " ",
            enabled = diag_enable(lsp_diagnostics_info, "warns"),
            hl = { fg = colors.yellow },
          },
          info = {
            provider = diag_of(lsp_diagnostics_info, "infos"),
            left_sep = " ",
            enabled = diag_enable(lsp_diagnostics_info, "infos"),
            hl = { fg = colors.blue },
          },
          hint = {
            provider = diag_of(lsp_diagnostics_info, "hints"),
            left_sep = " ",
            enabled = diag_enable(lsp_diagnostics_info, "hints"),
            hl = { fg = colors.cyan },
          },
        },
        lsp = {
          provider = "lsp_client_names",
          left_sep = " ",
          icon = icons.lsp,
          hl = { fg = colors.yellow },
        },
        git = {
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
        },
        gps = {
          provider = function()
            return require("nvim-gps").get_location()
          end,
          enabled = function()
            return require("nvim-gps").is_available()
          end,
          left_sep = " ",
          hl = { fg = colors.blue },
        },
      }

      local force_inactive = {
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
      }

      local components = {
        active = {
          {
            comps.vi_mode.left,
            comps.file.info,
            comps.diagnos.err,
            comps.diagnos.warn,
            comps.diagnos.hint,
            comps.diagnos.info,
            comps.gps,
          },
          {},
          {
            comps.git.add,
            comps.git.change,
            comps.git.remove,
            comps.lsp,
            comps.file.os,
            comps.git.branch,
            comps.line_percentage,
            comps.scroll_bar,
            comps.vi_mode.right,
          },
        },
        inactive = { { comps.vi_mode.left, comps.file.info }, {} },
      }

      require("feline").setup({
        colors = { bg = colors.bg, fg = colors.fg },
        vi_mode_colors = vi_mode_colors,
        force_inactive = force_inactive,
        components = components,
      })
    end,
  })
end
return M
