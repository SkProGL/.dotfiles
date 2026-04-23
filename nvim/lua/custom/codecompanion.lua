local M = {}

function M.setup(opts)
	local key = os.getenv("GUY_API")

	-- opts.adapters.http.gemini = function()
	-- 	return require("codecompanion.adapters").extend("gemini", {
	-- 		env = { },
	--
	-- 		schema = {
	-- 			model = {
	-- 				default = "gemini-3-flash-preview",
	-- 				-- default = "gemma-4-26b-a4b-it",
	-- 				-- default = "gemini-3.1-flash-lite-preview",
	-- 			},
	-- 		},
	-- 	})
	-- end

	-- api key
	opts.adapters.http.openai_responses = function()
		-- 		return require("codecompanion.adapters").extend("openai", {
		local c = {
			env = {
				api_key = key,
			},
			schema = {
				model = {
					default = "o4-mini",
					-- default = "gpt-5.4-mini",
					-- default = "gpt-5",
					-- default = "gpt-5.4-mini", -- or gpt-4.1 / gpt-4o
					-- default = "gpt-4o", -- or gpt-4.1 / gpt-4o
				},
			},
		}
		-- return require("codecompanion.adapters").extend("openai", c)
		return require("codecompanion.adapters").extend("openai_responses", c)
	end

	require("codecompanion").setup(opts)
	vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" })
	vim.keymap.set("v", "<leader>cc", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })
	-- vim.keymap.set(
	-- 	"v",
	-- 	"<leader>cc",
	-- 	"<cmd>CodeCompanionChat <cr>",
	-- 	{ desc = "Add selection to CodeCompanion Chat", silent = true }
	-- )
	vim.keymap.set("n", "<leader>ca", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })

	-- opts.strategies.chat.keymaps.confirm = "<C-s>"
end

return M
