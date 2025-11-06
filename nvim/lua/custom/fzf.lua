local fzf = require("fzf-lua")
-- fzf.setup({
-- 	buffers = {
-- 		-- sort_lastused = false,
-- 		previewer = "builtin",
-- 		numbers = "ordinal",
-- 		-- formatter = "path.filename_first", -- shows number + filename
-- 	},
-- })
vim.keymap.set("n", "<space>ef", fzf.files, { desc = "fzf files" })
vim.keymap.set("n", "<space>en", function()
	fzf.files({ cwd = "~/.config/nvim" })
end, { desc = "fzf nvim workspace" })
vim.keymap.set("n", "<space>eg", function()
	fzf.files({ cwd = "~" })
end, { desc = "fzf /root" })

vim.keymap.set("n", "<leader>ej", require("fzf-lua").live_grep, { desc = "grep word" }) -- content search (rg)
vim.keymap.set("n", "<leader>ek", require("fzf-lua").grep_cword, { desc = "grep word under cursor" }) -- search word under cursor
vim.keymap.set("n", "<leader>a", function()
	local bufs = vim.fn.getbufinfo({ buflisted = 1 })
	local list = {}
	for i, b in ipairs(bufs) do
		local name = b.name ~= "" and vim.fn.fnamemodify(b.name, ":~:.") or "[No Name]"
		list[i] = string.format("[%d] %s", i, name)
	end
	fzf.fzf_exec(list, {
		prompt = "Buffers> ",
		actions = {
			["default"] = function(sel)
				local i = tonumber(sel[1]:match("%[(%d+)%]"))
				if i then
					vim.cmd("buffer " .. bufs[i].bufnr)
				end
			end,
		},
	})
end, { desc = "fzf buffers (1..N)" })
