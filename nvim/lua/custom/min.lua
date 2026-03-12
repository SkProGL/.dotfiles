local M = {}

function M.create_buffer(lines)
	local deflect_buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_set_lines(deflect_buf, 0, -1, false, lines)
	vim.api.nvim_set_current_buf(deflect_buf)
	vim.api.nvim_buf_set_name(deflect_buf, "deflection.lua")
	return deflect_buf
end

function M.setup()
	vim.api.nvim_create_user_command("Deflect", function(opts)
		print(opts.args)
		local arg_start, arg_end = tonumber(opts.fargs[1]) - 1, tonumber(opts.fargs[2])
		local buf = vim.api.nvim_get_current_buf()
		local deflect_buf = M.create_buffer(vim.api.nvim_buf_get_lines(buf, arg_start, arg_end, false))
		-- store metadata
		vim.b[deflect_buf].history = {
			src_buf = buf,
			src_start = arg_start,
			src_end = arg_end,
			def_buf = deflect_buf,
			def_start = arg_start,
			def_end = arg_end,
		}

		-- intercept write
		vim.api.nvim_create_autocmd("BufWriteCmd", {
			buffer = deflect_buf,
			callback = function()
				local meta = vim.b[deflect_buf].history
				local edited = vim.api.nvim_buf_get_lines(deflect_buf, 0, -1, false)

				print("src range " .. meta.src_start .. " " .. meta.src_end - 1)
				print("edited Range 0 " .. #edited - 1)

				vim.api.nvim_buf_set_lines(meta.src_buf, meta.src_start, meta.src_end, false, edited)

				local delta = #edited - (meta.def_end - meta.def_start)
				meta.src_end = meta.src_end + delta
				meta.def_end = meta.def_end + delta

				vim.b[deflect_buf].history = meta
				print("Deflection applied")
				print("src range " .. meta.src_start .. " " .. meta.src_end - 1)
				print("edited Range 0 " .. #edited - 1)
			end,
		})
	end, { nargs = "+" })
end

return M
