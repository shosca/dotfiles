local present, packer = pcall(require, "packer")
if not present then
  local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  vim.notify("Cloning packer..")
  vim.fn.delete(install_path, "rf")
  vim.fn.system({ "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path })
  vim.api.nvim_command("packadd packer.nvim")
end

packer = require("packer")
packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "double" })
    end,
  },
  git = {
    clone_timeout = 6000, -- seconds
  },
  auto_clean = true,
  compile_on_sync = true,
  snapshot = nil,
})

local packages = {
  "sh.plugins",
  "sh.plugins.comment",
  "sh.plugins.git",
  "sh.plugins.ui",
  "sh.plugins.telescope",
  "sh.plugins.dap",
  "sh.plugins.lsp",
  "sh.plugins.luasnip",
  "sh.plugins.treesitter",
}

packer.startup({
  function(use)
    use("wbthomason/packer.nvim")
    use({ "lewis6991/impatient.nvim", rocks = "mpack" })
    for _, pkg in pairs(packages) do
      local configs = require(pkg).configure_packer()
      for _, config in pairs(configs) do
        use(config)
      end
    end
  end,
  config = {
    compile_path = vim.fn.stdpath("config") .. "/lua/packer_compiled.lua",
    display = {
      open_fn = function()
        return require("packer.util").float({ border = "rounded" })
      end,
    },
  },
})
packer.install()
packer.compile()
