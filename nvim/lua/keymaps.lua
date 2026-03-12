local common = require("common")

-- latest experimental change
vim.keymap.set("n", "E", "diw", { desc = "Rid of word" })

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

vim.keymap.set("n", "<leader>rq", function()
	local linux_dir = common.get_opened_dir()

	-- convert to windows path
	local win_path = vim.fn.system('wslpath -w "' .. linux_dir .. '"'):gsub("\n", "")

	-- copy to windows clipboard via clip.exe
	local job_id = vim.fn.jobstart({ "clip.exe" }, { detach = false })
	if job_id > 0 then
		vim.fn.chansend(job_id, win_path .. "\n")
		vim.fn.chanclose(job_id, "stdin")
	else
		print("failed to start clip.exe")
		return
	end

	print("copied windows path: " .. win_path)
end, { desc = "(copy path) windows" })

vim.keymap.set("n", "<leader>rw", function()
	-- convert wsl -> windows path
	local win_path = common.get_opened_dir(true)
	-- escape quotes for cmd
	local escaped = win_path:gsub('"', '\\"')

	-- fully detached powershell window that does not steal focus
	vim.fn.jobstart(
		{
			"powershell.exe",
			"-WindowStyle",
			"Hidden",
			"-Command",
			"Start-Process powershell.exe -ArgumentList '-NoExit','-Command','cd \""
				.. escaped
				.. "\"' -WindowStyle Normal",
		},
		{ detach = true }
	)
end, { desc = "(powershell) cwd detached" })

-- open in file explorer
vim.keymap.set("n", "<Leader>re", function()
	-- try to detect explorer.exe
	local explorer = vim.fn.executable("explorer.exe") == 1
	if explorer then
		vim.cmd("silent! !explorer.exe .")
	else
		vim.cmd("silent! !xdg-open .")
	end
end, { desc = "(file explorer) cwd" })

vim.keymap.set("n", "<leader>rr", function()
	-- get full linux path of current buffer
	local linux_path = vim.fn.expand("%:p")

	-- convert to windows-style path using wslpath
	local win_path = vim.fn.systemlist({ "wslpath", "-w", linux_path })[1]

	-- build proper file:// url for chrome
	local file_url = "file:///" .. win_path

	-- launch chrome without blocking neovim
	local browser = "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
	vim.fn.jobstart({
		vim.loop.fs_stat(browser) and browser
			or "/mnt/c/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe",
		file_url,
	}, { detach = true })
end, { noremap = true, silent = true, desc = "(chrome/brave) current file in browser " })

vim.keymap.set("n", "<Leader>rt", function()
	local dir = common.get_opened_dir(true)
	vim.fn.jobstart({ "code", dir }, { detach = true })
end, { desc = "(vscode) cwd" })

vim.keymap.set("n", "<leader>ra", function()
	vim.cmd([[%s/\r//g]])
end, { desc = "(CRLF -> LF) remove CR characters" })

-- center layout
vim.keymap.set("n", "<leader>rs", ":NoNeckPain<CR>", { desc = "Center layout", silent = true })

-- llm prompt
vim.keymap.set("n", "<leader>rd", function()
	local map = {
		[1] = "[TLDR] Give a TLDR",
		[2] = "[simple] Explain in simple terms",
		[3] = "[min fix] Give minimal fix",
		[4] = "[forget] Forget about previous code",
	}

	local s = "Choose prompt type\n\n"
	for key, value in ipairs(map) do
		s = s .. key .. " " .. value .. "\n"
	end

	vim.notify(s)
	local key = tonumber(vim.fn.nr2char(vim.fn.getchar()))
	local prepend = ""
	if key then
		prepend = map[key]:gsub("%b[] ", "") .. ".\n"
	else
		return
	end

	local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	local q = vim.fn.input("Your question: ")
	vim.fn.setreg("+", prepend .. q .. "\n\n" .. content)
	-- vim.notify("\n[prompt yanked]")
	print()
end, { desc = "[create prompt] Create prompt with full code attached" })

function curl_lookup()
	print("[loading]")
	local w = vim.fn.expand("<cword>")
	local o = vim.fn.system(([[
	curl -s "https://lingva.ml/api/v1/auto/ru/hello" | python3 -c "import sys, json; print(json.load(sys.stdin)['translation'])"
	]]):gsub("hello", w))
	-- vim.cmd("vnew | setlocal buftype=nofile bufhidden=wipe noswapfile")
	-- vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(o, "\n"))
	vim.notify(o)
end

vim.keymap.set("n", "<leader>vv", function()
	curl_lookup()
end, { desc = "[curl] Translate" })

vim.keymap.set("n", "<leader>vg", function()
	local w = vim.fn.expand("<cword>")
	local o = ([[xdg-open https://www.google.com/search?q=hello]]):gsub("hello", w)
	vim.fn.system(o)
end, { desc = "[xdg] Google lookup" })

vim.keymap.set("n", "<leader>vf", function()
	print("[loading]")
	local w = vim.fn.expand("<cword>")
	local o = vim.fn.system(([[
curl -s https://api.dictionaryapi.dev/api/v2/entries/en/hello | python3 -c "import sys, json; print(json.load(sys.stdin))"
	]]):gsub("hello", w))
	-- vim.cmd("vnew | setlocal buftype=nofile bufhidden=wipe noswapfile")
	-- vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(o, "\n"))
	print(o)
end, { desc = "[curl] Translate" })
