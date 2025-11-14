-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("config.lazy")
require("keymaps")
require("options")

-- make all comments lowercase
-- %s/#.*$/\L&

-- evaluate selected line as math expression
-- !bc

-- restart ripgrep and WSL
-- sudo umount /mnt/c
-- sudo mount -t drvfs C: /mnt/c

-- highlight copied text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- open in file explorer
vim.keymap.set("n", "<Leader>r", function()
	-- try to detect explorer.exe
	local explorer = vim.fn.executable("explorer.exe") == 1
	if explorer then
		vim.cmd("silent! !explorer.exe .")
	else
		vim.cmd("silent! !xdg-open .")
	end
end, { desc = "Open in file explorer" })

-- format file
vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file or selection" })

-- auto-recompute folds on open
-- vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
-- 	pattern = "*",
-- 	callback = function(args)
-- 		vim.schedule(function()
-- 			vim.api.nvim_buf_call(args.buf, function()
-- 				vim.cmd("silent! normal! zx")
-- 			end)
-- 		end)
-- 	end,
-- })

-- select function
require("nvim-treesitter.configs").setup({
	textobjects = {
		select = {
			enable = true,
			lookahead = true, -- automatically jump forward to textobj
			keymaps = {
				["af"] = "@function.outer", -- a function (outer = whole function incl. signature)
				["if"] = "@function.inner", -- inner part (just the body)
			},
		},
	},
})

vim.diagnostic.config({
	virtual_text = true, -- error lens
	signs = false, -- sign next to line number
	float = { border = "rounded" },
})

-- disable comment on nextline (lua only)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function()
		vim.opt_local.formatoptions:remove({ "o", "r" })
	end,
})

-- List python functions with "def name(args):" in a scratch buffer
local function list_py_funcs()
	local parser = vim.treesitter.get_parser(0, "python")
	if not parser then
		return print("No Treesitter parser for Python")
	end

	local query = vim.treesitter.query.parse(
		"python",
		[[
    (function_definition
      name: (identifier) @name
      parameters: (parameters) @params)
  ]]
	)

	local root = parser:parse()[1]:root()
	local funcs, buf = {}, 0

	for id, node in query:iter_captures(root, buf, 0, -1) do
		local cap = query.captures[id]
		local text = vim.treesitter.get_node_text(node, buf):gsub("\n%s*", " ")
		if cap == "name" then
			funcs[#funcs + 1] = { name = text, params = "" }
		else
			funcs[#funcs].params = text
		end
	end

	local lines = {}
	for _, f in ipairs(funcs) do
		lines[#lines + 1] = "def " .. f.name .. f.params .. ":"
	end

	vim.cmd("new | setlocal buftype=nofile bufhidden=wipe noswapfile")
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

vim.api.nvim_create_user_command("ListFunctions", list_py_funcs, {})

-- adapt colorscheme on buffer change
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		local ft = vim.bo.filetype
		local material_fts = {
			javascript = true,
			javascriptreact = true,
			typescript = true,
			typescriptreact = true,
			html = true,
			css = true,
			lua = true,
			dosbatch = true,
		}

		if material_fts[ft] then
			vim.cmd("colo material")
			vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "material" })
		else
			vim.cmd("colo melange")
			vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "melange" })
		end
	end,
})

-- -- toggle between None / True / False in python
-- local function toggle_python_literal()
-- 	local word = vim.fn.expand("<cword>")
--
-- 	-- case 1: numbers should use normal increment/decrement
-- 	if tonumber(word) ~= nil then
-- 		return false
-- 	end
--
-- 	-- case 2: directly on keyword
-- 	if word == "True" then
-- 		vim.cmd("normal! ciwFalse")
-- 		return true
-- 	elseif word == "False" then
-- 		vim.cmd("normal! ciwNone")
-- 		return true
-- 	elseif word == "None" then
-- 		vim.cmd("normal! ciwTrue")
-- 		return true
-- 	end
--
-- 	-- case 3: search current line for keyword
-- 	local line = vim.fn.getline(".")
-- 	local col = line:find("%f[%w](True)%f[%W]") or line:find("%f[%w](False)%f[%W]") or line:find("%f[%w](None)%f[%W]")
--
-- 	if col then
-- 		vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), col - 1 })
-- 		return toggle_python_literal()
-- 	end
--
-- 	-- case 4: nothing to toggle
-- 	return false
-- end
--
-- -- wrapper for <c-a>
-- local function custom_ctrl_a()
-- 	if not toggle_python_literal() then
-- 		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-a>", true, false, true), "n", true)
-- 	end
-- end
--
-- -- wrapper for <c-x>
-- local function custom_ctrl_x()
-- 	if not toggle_python_literal() then
-- 		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-x>", true, false, true), "n", true)
-- 	end
-- end

-- keymaps
-- vim.keymap.set("n", "<C-a>", custom_ctrl_a, { noremap = true, silent = true })
-- vim.keymap.set("n", "<C-x>", custom_ctrl_x, { noremap = true, silent = true })

-- vim.keymap.set("n", "<leader>o", function()
-- 	vim.cmd([[botright vsplit | terminal cmd.exe /k "..\.venv\Scripts\activate.bat && python debug_info.py"]])
-- 	vim.cmd([[vertical resize 40]])
-- 	vim.cmd([[file uv_venv]])
-- end, { desc = "Run app.py in Windows venv" })
vim.keymap.set("n", "<leader>o", function()
	local existing_buf = nil
	local existing_win = nil

	-- Find if uv_venv buffer already exists and is visible in a window
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local name = vim.api.nvim_buf_get_name(buf)
		if name:match("uv_venv$") then
			existing_buf = buf
			existing_win = win
			break
		end
	end

	if existing_buf or existing_win then
		-- Focus the window
		vim.api.nvim_set_current_win(existing_win)
		-- Send command to rerun Python script
		vim.fn.chansend(vim.b.terminal_job_id, "cls && python debug_info.py\r")
	else
		-- clean up any hidden buffers named uv_venv
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			local name = vim.api.nvim_buf_get_name(buf)
			if name:match("uv_venv$") then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end
		-- Otherwise create new terminal split and run script
		vim.cmd(
			[[botright vsplit | terminal cmd.exe /k "..\.venv\Scripts\activate.bat && cls && python debug_info.py"]]
		)
		vim.cmd([[vertical resize 40]])
		-- pcall(vim.cmd([[file uv_venv]]))
		pcall(vim.cmd, "file uv_venv")
	end
	-- go back to previous window
	vim.cmd("wincmd w")
end, { desc = "Run or reuse venv terminal (focus before reusing)" })

vim.keymap.set("n", "<leader>O", function()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local name = vim.api.nvim_buf_get_name(buf)
		if name:match("uv_venv$") then
			vim.api.nvim_set_current_win(win)
			vim.cmd("close") -- close that window
			return
		end
	end
	print("No uv_venv window to close")
end, { desc = "Close venv terminal window if open" })

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

-- vim.keymap.set('n', '<leader>hh', function()
--   local path = vim.fn.expand('%:p')
--   vim.cmd('silent !/mnt/c/Program\\ Files/Google/Chrome/Application/chrome.exe "file:///' .. path .. '"')
-- end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>hh", function()
	-- Get full Linux path of current buffer
	local linux_path = vim.fn.expand("%:p")

	-- Convert to Windows-style path using wslpath
	local win_path = vim.fn.systemlist({ "wslpath", "-w", linux_path })[1]

	-- Build proper file:// URL for Chrome
	local file_url = "file:///" .. win_path

	-- Launch Chrome without blocking Neovim
	local browser = "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
	vim.fn.jobstart({
		-- "",
		vim.loop.fs_stat(browser) and browser or
		"/mnt/c/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe",
		file_url,
	}, { detach = true })
end, { noremap = true, silent = true })
