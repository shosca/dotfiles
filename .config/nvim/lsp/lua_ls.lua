return {
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,
      },
      runtime = {
        version = "LuaJIT",
      },
      telemetry = { enable = false },
      diagnostics = {
        globals = { "vim" },
      },
      hint = { enable = true },
      completion = {
        callSnippet = "Replace",
      },
    },
  },
}
