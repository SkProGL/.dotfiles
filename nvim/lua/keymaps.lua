-- center when scroll
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- clear highlight on ESC
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<Leader>t", ":echo 'Leader works!'<CR>", { desc = "Test leader key" })

-- switch between buffers
vim.keymap.set("n", "<A-l>", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<A-h>", ":bprevious<CR>", { silent = true })

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Escape insert mode in tmux" })

vim.keymap.set("n", "<leader>ww", vim.diagnostic.setloclist, { desc = "Open diagnostics in location list" })
-- vim.keymap.set("n", "<leader>wr", ":LspRestart<CR>", { desc = "Restart lsp", silent = true })
vim.keymap.set("n", "<leader>wr", function()
	vim.cmd("LspRestart")
	-- clear diagnostics after restart
	vim.schedule(function()
		vim.diagnostic.reset()
	end)
end, { desc = "Restart LSP and clear diagnostics", silent = true })


-- center layout
vim.keymap.set("n", "<leader>rs", ":NoNeckPain<CR>", { desc = "Center layout" , silent = true })
