local M = {}
function M.get_opened_dir(win_path)
	local linux_path = ""
	local path = ""

	-- if current buffer is oil, return cwd
	if vim.bo.filetype == "oil" then
		path = vim.fn.getcwd()
	else
		-- otherwise return directory of current buffer
		path = vim.fn.expand("%:p:h")
	end

	if win_path then
		-- convert to windows path
		path = vim.fn.system('wslpath -w "' .. path .. '"'):gsub("\n", "")
	end

	return path
end

return M
