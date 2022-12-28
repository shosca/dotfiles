return {
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
}
