local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

vim.keymap.set("n", "<leader>b", function()
	local var = vim.fn.expand("<cword>")

	-- open new line
	vim.cmd("normal! o")
	ls.snip_expand(ls.s("", {
		t({ "for " }),
		i(1, "i"),
		t({ " in range(len(" .. var .. ")):" }),
		t({ "", "\tprint(" }),
		i(2, "i"),
		t({ ")" }),
	}))
end, { desc = "Experimental for loop" })

vim.keymap.set("n", "<leader>bp", function()
	local var = vim.fn.expand("<cword>")

	-- open new line
	vim.cmd("normal! o")
	ls.snip_expand(ls.s("", {
		-- start on a new line
		t({ "", 'print(f"\\033[43m\\033[30m{' .. var .. '=}\\033[0m")' }),
	}))
end, { desc = "Experimental print" })

ls.add_snippets("python", {

	-- trigger is `f`
	s("jsn", {
		-- start on a new line with `for `
		t({ "", "print(json.dumps(" }),
		i(0, "dev"),
		-- line break + indentation
		t({ ".__dict__, indent=4, default=str))" }),
	}),

	s("wj", {
		-- start on a new line with `for `
		t({ "", 'print(f"\\033[43m\\033[30m{' }),
		i(0, "i"),
		-- line break + indentation
		t({ '=}\\033[0m")' }),
	}),
	s("wk", {
		-- start on a new line with `for `
		t({ "", 'print(f"\\033[42m\\033[30m{' }),
		i(0, "i"),
		-- line break + indentation
		t({ '=}\\033[0m")' }),
	}),
	s("with", {
		t({ "with open(" }),
		i(1, "file"),
		t({ ", '" }),
		i(2, "w"),
		t({ "') as f:" }),
		t({ "", "\tf.write()" }),
	}),

	s("for", {
		t({ "for " }),
		i(1, "i"),
		t({ " in range(len(" }),
		i(2, "a"),
		t({ ")):" }),
		t({ "", "\tprint(i)" }),
		i(3, "i"),
		t({ ")" }),
	}),
})
