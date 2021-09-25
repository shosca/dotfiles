local configs = require 'lspconfig/configs'
local util = require 'lspconfig/util'
local secrets = require 'sh.secrets'

local server_name = 'sourcery'

configs[server_name] = {
  default_config = {
    cmd = {server_name, 'lsp'},
    filetypes = {'python'},
    init_options = {editor_version = 'vim', extension_version = 'vim.lsp', token = secrets.sourcery.token},
    root_dir = function(fname)
      local root_files = {'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile'}
      return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname) or util.path.dirname(fname)
    end
  },
  docs = {
    description = [[
https://github.com/sourcery-ai/sourcery

Refactor Python instantly using the power of AI.
]]
  }
}
