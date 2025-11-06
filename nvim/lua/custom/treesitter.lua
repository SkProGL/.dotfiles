local configs = require("nvim-treesitter.configs")

configs.setup({
	ensure_installed = { "python", "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "css" },
	sync_install = false,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = { enable = true },
	refactor = {
		highlight_definitions = { enable = true },
		highlight_current_scope = { enable = true },
	},

	 incremental_selection = {
	 	enable = true,
	 	keymaps = {
	 		init_selection = "<Enter>",
	 		node_incremental = "<Enter>",
	 		scope_incremental = false,
	 		node_decremental = "<Backspace>",
	 	},
	 },
})
-- fix highlighting in python
vim.api.nvim_set_hl(0, "@type.python", { link = "@variable.python" })
vim.api.nvim_set_hl(0, "@constant.python", { link = "@variable.python" })
-- vim.api.nvim_set_hl(0, '@function.python', { link = '@variable.python' })
