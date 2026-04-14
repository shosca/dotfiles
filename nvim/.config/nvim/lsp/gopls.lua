return {
  init_options = { usePlaceholders = true, completeUnimported = true },
  settings = {
    gopls = {
      codelenses = { test = true },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = { unusedparams = true },
      staticcheck = true,
    },
  },
}
