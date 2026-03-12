local M = {}

local function leave_visual()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
end

function M.focus_selection()
	--- keeps unfolded selected lines only
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	local last = vim.api.nvim_buf_line_count(0)

	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end

	vim.wo.foldmethod = "manual"
	vim.cmd("normal! zE")

	if start_line > 1 then
		vim.cmd(("1,%dfold"):format(start_line - 1))
	end

	if end_line < last then
		vim.cmd(("%d,%dfold"):format(end_line + 1, last))
	end
end

function M.setup()
	vim.keymap.set("n", "gg", function()
		vim.cmd("normal! gg")
		if vim.fn.foldclosed(".") ~= -1 then
			vim.cmd("normal! j")
		end
	end)
	vim.keymap.set("n", "G", function()
		vim.cmd("normal! G")
		if vim.fn.foldclosed(".") ~= -1 then
			vim.cmd("normal! k")
		end
	end)
	vim.keymap.set("x", "E", function()
		leave_visual()
		M.focus_selection()
	end)
end

return M
