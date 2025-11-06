-- lua/custom/lsp_fzf_keys.lua
local M = {}

function M.setup()
	local ok, fzf = pcall(require, "fzf-lua")
	if not ok then
		return
	end

	local aug = vim.api.nvim_create_augroup("LspFzfKeys", { clear = true })
	vim.api.nvim_create_autocmd("LspAttach", {
		group = aug,
		callback = function(ev)
			local map = function(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
			end
			map("<leader>gs", fzf.lsp_document_symbols, "[lsp] document symbols (fzf)")
			map("<leader>gS", fzf.lsp_workspace_symbols, "[lsp] workspace symbols (fzf)")
			-- map("<leader>g", fzf.lsp_live_workspace_symbols, "[lsp] symbols (fzf live)")
			map("<leader>dd", fzf.diagnostics_document, "[lsp] document diagnostics (fzf)")
			map("<leader>dD", fzf.diagnostics_workspace, "[lsp] workspace diagnostics (fzf)")
			map("<leader>gr", vim.lsp.buf.rename, "[lsp] rename references")
		end,
	})
end

return M
