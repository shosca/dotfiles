local M = {}

function M.configure_packer(use)
	use({
		"L3MON4D3/LuaSnip",
		requires = { "rafamadriz/friendly-snippets" },
		config = function()
			local ls = require("luasnip")
			require("luasnip.loaders.from_vscode")
			ls.config.set_config({
				enable_autosnippets = true,
				history = true,
				updateevents = "TextChanged,TextChangedI",
			})
		end,
	})
end
return M
