vim.opt.clipboard = "unnamedplus"
vim.opt.fileformats = { "unix", "dos" }
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.ignorecase = true -- case insensitive search
vim.opt.smartcase = true -- case sensitive search when uppercase used

-- enables better folding using treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99 -- keeps functions open unless folded manually

-- vim.opt.scrolloff = math.floor(vim.opt.lines:get() / 2)
vim.opt.scrolloff = 10

-- nvim theme
vim.opt.termguicolors = true
vim.cmd.colorscheme("melange")
-- vim.cmd.colorscheme("material")
