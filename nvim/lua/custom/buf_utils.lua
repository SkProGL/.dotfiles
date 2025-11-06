local M = {}

-- usage counter
local buf_usage = {}

-- decay every 5 minutes
vim.fn.timer_start(5 * 60 * 1000, function()
	for k, v in pairs(buf_usage) do
		buf_usage[k] = math.floor(v * 0.9)
	end
end, { ["repeat"] = -1 })

-- also reset at startup
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		buf_usage = {}
	end,
})
-- -- increment count on BufEnter
-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	callback = function(args)
-- 		local bufnr = args.buf
-- 		buf_usage[bufnr] = (buf_usage[bufnr] or 0) + 1
-- 	end,
-- })

local last_buf = nil
local current_buf = nil

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function(args)
		if current_buf and vim.api.nvim_buf_is_valid(current_buf) then
			last_buf = current_buf
		end
		current_buf = args.buf
	end,
})

function M.get_last_buf()
	return last_buf
end

-- return buffers sorted by usage
-- function M.get_sorted_buffers()
-- 	local bufs = vim.fn.getbufinfo({ buflisted = 1 })
-- 	table.sort(bufs, function(a, b)
-- 		return (buf_usage[a.bufnr] or 0) > (buf_usage[b.bufnr] or 0)
-- 	end)
-- 	return bufs
-- end

-- cache of last sorted buffers
local last_sorted = {}

function M.get_sorted_buffers()
	local bufs = vim.fn.getbufinfo({ buflisted = 1 })
	table.sort(bufs, function(a, b)
		return (buf_usage[a.bufnr] or 0) > (buf_usage[b.bufnr] or 0)
	end)
	last_sorted = bufs
	return bufs
end

-- expose last snapshot (does not recompute)
function M.get_last_sorted_buffers()
	return last_sorted
end

-- format label for a buffer (used in lualine, fzf, etc.)
function M.format_buffer_label(b, idx, keys, current)
	local name
	if b.name == "" then
		name = "[No Name]"
	elseif b.name:match("^oil://") then
		name = ":Oil"
	else
		name = vim.fn.fnamemodify(b.name, ":t")
	end

	-- if vim.bo[b.bufnr].modified then
	-- 	name = "+ " .. name
	-- end
	-- local label_key = keys[idx] or tostring(idx)
	-- local label = string.format("[%s] %s", label_key, name)
	--
	-- if b.bufnr == current then
	-- 	label = "***" .. label
	-- end
	--
	-- return label

	local key = keys[idx] or tostring(idx)

	-- if current buffer
	if b.bufnr == current then
		-- key = "*" .. key
		key = "▊" .. key
	else
		key = "" .. key
	end

	-- if modified
	if vim.bo[b.bufnr].modified then
		key = "+" .. key
	else
		key = "" .. key
	end

	-- final label
	return string.format("%s/%s ", key, name)
end
function M.get_buffer_components(keys)
	local bufs = M.get_sorted_buffers()
	local cur = vim.api.nvim_get_current_buf()
	local items = {}

	for i, b in ipairs(bufs) do
		local label = M.format_buffer_label(b, i, keys, cur)
		local key, name = label:match("^(.-)/(.*)$")

		if key and name then
			table.insert(items, key .. "/") -- first part
			table.insert(items, name) -- second part
		else
			table.insert(items, label) -- fallback if no "/"
		end
	end

	return items
end
return M
