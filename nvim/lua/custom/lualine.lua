-- require("lualine").setup()
local mode_map = {
	n = "N",
	no = "N?",
	i = "I",
	v = "V",
	V = "VL",
	["\22"] = "VB", -- CTRL-V
	R = "R",
	Rv = "VR",
	c = "!",
	s = "S",
	S = "SL",
	["\19"] = "SB", -- CTRL-S
	t = "T",
}
-- show attached lsp name
local function get_formatter_name()
	local formatters = require("conform").list_formatters_to_run(0)
	if #formatters > 0 then
		return formatters[1].name
	end
	return "no_formatter"
end
-- show attached lsp name
local function get_lsp_name()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	if next(clients) == nil then
		return "no_lsp"
	end
	local names = {}
	for _, client in pairs(clients) do
		table.insert(names, client.name)
	end
	return table.concat(names, ",")
end
local function formatter_and_lsp()
	return get_formatter_name() .. "/" .. get_lsp_name()
end

local buf_utils = require("custom.buf_utils")
local keys = { "A", "S", "D", "F", "Q", "W", "E", "R", "1", "2" }

local function current_filename()
	local cur = vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(cur)

	-- handle special cases
	if name == "" then
		name = "[No Name]"
	elseif name:match("^oil://") then
		name = ":Oil"
	else
		name = vim.fn.fnamemodify(name, ":t") -- only filename
	end

	if vim.bo[cur].modified then
		name = name .. " [+]"
	end

	return name
end
local comps = buf_utils.get_buffer_components(keys)
-- build lualine_b dynamically
local buffer_components = {}
for i = 1, 20 do -- choose max slots you want
	table.insert(buffer_components, {
		function()
			return buf_utils.get_buffer_components(keys)[i] or ""
		end,
		color = (i % 2 == 0) and { fg = "#ffffff", bg = "#1e1e2e" } -- even = bw
			or { fg = "#ff8800", bg = "#1e1e2e" }, -- odd = orange
		separator = { left = "", right = "" },
		padding = 0,
	})
end
-- local buffer_components = {}
-- for i = 1, 10 do -- choose max slots you want
-- 	table.insert(buffer_components, {
-- 		function()
-- 			return buf_utils.get_buffer_components(keys)[i] or ""
-- 		end,
-- 		color = { fg = "#ff8800", bg = "#1e1e2e" },
-- 		separator = { left = "|", right = "|" }, -- optional: keep tight spacing
-- 		padding = 0,
-- 	})
-- end
require("lualine").setup({
	options = {
		globalstatus = true,
	},
	sections = {
		lualine_a = {
			function()
				local mode = vim.api.nvim_get_mode().mode
				return mode_map[mode] or mode
			end,
		},
		-- lualine_b = {
		-- 	{
		-- 		-- "filename",
		-- 		buffer_list,
		-- 		path = 0,
		-- 		color = { fg = "#ff8800", bg = "#1e1e2e" },
		-- 		symbols = { modified = " [+]", readonly = " [RO]", unnamed = "[No Name]" },
		-- 		separator = { left = "", right = "" },
		-- 	},
		-- 	{
		-- 		current_filename,
		-- 		color = { fg = "#ffffff", bg = "#000000" },
		-- 		separator = { left = "", right = "" },
		-- 	},
		-- },
		lualine_b = buffer_components,

		lualine_c = {},
		lualine_x = {

			{
				"diagnostics",
				sources = { "nvim_diagnostic" },
				sections = { "error", "warn", "info", "hint" },
				symbols = { error = " ", warn = " ", info = " ", hint = " " },
				colored = true,
				update_in_insert = false,
				always_visible = false,
				-- color = { bg = "#ff8800", fg = "#ffffff" }, -- dark orange background, white text
				-- color = { bg = "#1e1e1e", fg = "#ff8800" }, -- dark orange background, white text
				color = function()
					local hl = vim.api.nvim_get_hl_by_name("lualine_b_normal", true)
					return { fg = string.format("#%06x", hl.foreground), bg = string.format("#%06x", hl.background) }
				end,
			},

			{
				"diff",
				separator = { left = "", right = "" },
			},
			-- "location",
		},
		lualine_y = {
			function()
				return os.date("%H:%M") -- shows 24h time like 14:37
			end,
		},
		lualine_z = { formatter_and_lsp },
	},
})

--
-- local keys = { "a", "s", "d", "f", "q", "w", "e", "r", "1", "2" }
--
-- for i, key in ipairs(keys) do
-- 	vim.keymap.set("n", "<A-" .. key .. ">", function()
-- 		local bufs = vim.fn.getbufinfo({ buflisted = 1 })
-- 		if bufs[i] then
-- 			vim.cmd("buffer " .. bufs[i].bufnr)
-- 		end
-- 	end, { desc = "Go to buffer " .. i })
-- end

vim.keymap.set("n", "<A-0>", function()
	local bufnr = vim.api.nvim_get_current_buf()
	if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
		vim.cmd("bdelete " .. bufnr)
	end
	vim.cmd("redrawstatus")
end, { silent = true, desc = "Close buffer" })
-- vim.keymap.set("n", "<A-0>", ":bd<CR>", { silent = true, desc = "Close buffer" })

-- alt + - switch to previous buffer
-- vim.keymap.set("n", "<A-->", "<cmd>b#<CR>", { noremap = true, silent = true })

-- vim.keymap.set("n", "<A-->", function()
-- 	-- jump to the previous buffer in custom importance order (the same snapshot used by lualine),
-- 	-- wrapping around (when buffer was just closed),
-- 	-- so buffer navigation matches the visual buffer list
-- 	local bufs = buf_utils.get_last_sorted_buffers() -- shared snapshot from lualine
-- 	local cur = vim.api.nvim_get_current_buf()
-- 	local idx
--
-- 	for i, b in ipairs(bufs) do
-- 		if b.bufnr == cur then
-- 			idx = i
-- 			break
-- 		end
-- 	end
--
-- 	if idx and idx > 1 then
-- 		vim.cmd("buffer " .. bufs[idx - 1].bufnr)
-- 	elseif idx then
-- 		-- wrap around to last buffer
-- 		vim.cmd("buffer " .. bufs[#bufs].bufnr)
-- 	end
-- end, { noremap = true, silent = true, desc = "Previous buffer (custom order)" })

-- local buf_utils = require("custom.buf_utils")

local keys = { "a", "s", "d", "f", "q", "w", "e", "r", "1", "2" }

-- also update Alt-<key> mappings
-- for i, key in ipairs(keys) do
-- 	vim.keymap.set("n", "<A-" .. key .. ">", function()
-- 		local bufs = buf_utils.get_sorted_buffers()
-- 		if bufs[i] then
-- 			vim.cmd("buffer " .. bufs[i].bufnr)
-- 		end
-- 	end, { desc = "Go to buffer " .. i })
-- end

local comps = buf_utils.get_buffer_components(keys)
for i, key in ipairs(keys) do
	vim.keymap.set("n", "<A-" .. key .. ">", function()
		local bufs = buf_utils.get_last_sorted_buffers()
		if bufs[i] then
			vim.cmd("buffer " .. bufs[i].bufnr)
		end
	end, { desc = "Go to buffer " .. i })
end

vim.keymap.set("n", "<A-->", function()
	local last = buf_utils.get_last_buf()
	local cur = vim.api.nvim_get_current_buf()

	-- always recompute the latest importance order
	local bufs = buf_utils.get_sorted_buffers()

	-- prefer last buffer if valid + in sorted list
	if last and vim.api.nvim_buf_is_valid(last) then
		for _, b in ipairs(bufs) do
			if b.bufnr == last then
				vim.cmd("buffer " .. last)
				return
			end
		end
	end

	-- fallback: pick the first available buffer (most used) that isn’t the current one
	for _, b in ipairs(bufs) do
		if b.bufnr ~= cur and vim.api.nvim_buf_is_valid(b.bufnr) then
			vim.cmd("buffer " .. b.bufnr)
			return
		end
	end
end, { noremap = true, silent = true, desc = "Go to last buffer (fallback to most used)" })

-- vim.keymap.set("n", "<A-->", function()
-- 	local last = buf_utils.get_last_buf()
-- 	if last and vim.api.nvim_buf_is_valid(last) then
-- 		vim.cmd("buffer " .. last)
-- 	end
-- end, { noremap = true, silent = true, desc = "Go to last buffer (true toggle)" })
