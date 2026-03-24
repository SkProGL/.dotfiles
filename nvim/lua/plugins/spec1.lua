return {
	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
		config = function()
			require("custom.fzf")
		end,
	},
	{
		"savq/melange-nvim",
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		--- stylua: ignore
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
			-- { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
		},
	},
	{
		"stevearc/oil.nvim",
		opts = {},
		-- dependencies = { { "echasnovski/mini.icons", opts = {} } },
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
		-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
		lazy = false,
		config = function()
			require("oil").setup({ view_options = { show_hidden = true } })
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

			-- vim.keymap.set("n", "<Leader>-", "<cmd>Oil<CR>", { desc = "Open Oil in current dir" })
			vim.keymap.set("n", "<leader>n", function()
				local home = os.getenv("HOME")
				require("oil").open(home .. "/.config/nvim")
			end, { desc = "Open oil.nvim in ~/.config/nvim" })
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("custom.treesitter")
			require("nvim-treesitter.configs").setup({
				playground = { enable = true },
				-- (for html) indent does not always work as expected
				-- indent = {
				-- 	enable = false,
				-- },
			})
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	},
	{
		"williamboman/mason.nvim",
		config = true,
	},
	{
		-- sudo apt install nodejs xclip npm pipx
		-- curl https://sh.rustup.rs -sSf | sh
		-- cargo install stylua

		-- sudo apt remove fzf
		-- git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
		-- ~/.fzf/install

		"WhoIsSethDaniel/mason-tool-installer.nvim",
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"stylua", -- lua
					"stylelint", -- css, javascript, html
					"lua_ls",
					"prettierd", -- css, javascript, html
					"prettier",
					"djlint",
					"emmet_language_server",
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		opts = {},
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					-- conform will run multiple formatters sequentially
					python = { "autopep8" },
					-- conform will run the first available formatter

					css = { "prettierd", "prettier", stop_after_first = true }, -- CSS formatter added
					html = { "prettierd", "prettier", stop_after_first = true },
					-- html = { "djlint" },
					javascript = { "prettierd", "prettier", stop_after_first = true },
				},
				formatters = {
					prettier = {
						prepend_args = { "--print-width", "200", "--prose-wrap", "preserve" },
					},
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
	{
		"folke/persistence.nvim",
		event = "BufReadPre", -- this will only start session saving when an actual file was opened
		opts = {
			-- add any custom options here
		},

		config = function()
			require("persistence").setup(opts)
			-- load the session for the current directory
			vim.keymap.set("n", "<leader>qs", function()
				require("persistence").load()
			end, { desc = "[persistence] load session for current directory" })

			-- select a session to load
			vim.keymap.set("n", "<leader>qS", function()
				require("persistence").select()
			end, { desc = "[persistence] select session" })

			-- load the last session
			vim.keymap.set("n", "<leader>ql", function()
				require("persistence").load({ last = true })
			end, { desc = "[persistence] load last session" })

			-- stop persistence => session won't be saved on exit
			vim.keymap.set("n", "<leader>qd", function()
				require("persistence").stop()
			end, { desc = "[persistence] stop" })
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },

		config = function()
			require("custom.lualine")
		end,
	},
	{
		"mbbill/undotree",
		keys = {
			{ "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle UndoTree" },
		},
		cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeHide", "UndotreeFocus" },
		init = function()
			vim.g.undotree_WindowLayout = 2
			vim.g.undotree_SetFocusWhenToggle = 1
		end,
	},
	{
		"numToStr/Comment.nvim",
		opts = {},
		config = function()
			-- normal mode - comment current line
			vim.keymap.set("n", "<C-_>", "gcc", { remap = true, silent = true })

			-- visual mode - comment selection
			vim.keymap.set("v", "<C-_>", "gc", { remap = true, silent = true })
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"pyright",
					"pylsp",
					"ts_ls",
					"eslint",
					"html",
					"lua_ls",
					"emmet_language_server",
					-- "rust_analyzer",
				}, -- list of LSPs to auto-install
				automatic_enable = false,
			})

			-- local lspconfig = require("lspconfig")

			-- lspconfig.pyright.setup({})
			-- vim.lsp.enable("pyright")
			vim.lsp.config.lua_ls = {
				settings = {
					Lua = {
						hint = {
							enable = true,
							setType = true,
							paramType = true,
							paramName = "All",
							semicolon = "Disable",
							arrayIndex = "Enable",
						},
						-- enables autosuggestions for vim.
						diagnostics = { globals = { "vim" } },
						workspace = {
							checkThirdParty = false,
							library = {
								vim.env.VIMRUNTIME,
							},
						},
					},
				},
			}

			vim.lsp.enable("lua_ls")
			-- lspconfig.pylsp.setup({
			vim.lsp.config.pylsp = {
				settings = {
					pylsp = {
						plugins = {
							jedi_definition = { enabled = true },
							pycodestyle = {
								ignore = { "E501", "E226" },
								-- maxLineLength = 120,
							},
						},
					},
				},
			}

			vim.lsp.enable("pylsp")

			-- lspconfig.ts_ls.setup({
			vim.lsp.config.ts_ls = {
				settings = {
					-- example: disable tsserver formatting so you can use prettier instead
					typescript = { format = { enable = false } },
					javascript = { format = { enable = false } },
				},
			}

			-- lspconfig.eslint.setup({})
			-- require("custom.lsp").setup()

			vim.lsp.enable("ts_ls")

			vim.lsp.config.eslint = {}
			-- vim.lsp.start(vim.lsp.config.eslint)
			vim.lsp.enable("eslint")
			vim.lsp.enable("html")
			vim.lsp.enable("emmet_language_server")
			-- vim.lsp.inlay_hint.enable(true)
			require("custom.lsp").setup()
		end,
	},
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		version = "1.*",
		dependencies = { "rafamadriz/friendly-snippets", "L3MON4D3/LuaSnip", version = "v2.*" },
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			-- keymap = { preset = "default" },
			snippets = { preset = "luasnip" },
			keymap = {
				-- set to 'none' to disable the 'default' preset
				preset = "default",
				-- ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-space>"] = { "hide", "show" },
				["<C-e>"] = { "show", "hide_documentation", "show_documentation" },
				-- ["<CR>"] = { "select_and_accept", "fallback" },
				["<CR>"] = { "accept", "fallback" },

				["<C-k>"] = { "select_prev", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },

				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },

				["<Tab>"] = { "snippet_forward", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "fallback" },

				["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
				["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
				["<C-l>"] = { "show_signature", "hide_signature", "fallback" },
			},

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},
			-- (Default) Only show the documentation popup when manually triggered
			completion = {
				documentation = { auto_show = false },
			},

			-- Default list of enabled providers defined so that you can extend it
			sources = {
				default = { "snippets", "lsp", "path", "buffer" },
			},

			-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		-- opts_extend = { "sources.default" },
	},

	{
		"kaicataldo/material.vim",
		config = function()
			vim.g.material_theme_style = "darker"
		end,
	},

	{
		"L3MON4D3/LuaSnip",
		-- follow latest release.
		version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		build = "make install_jsregexp",

		config = function()
			require("custom.luasnip")
		end,
	},
	-- core dap plugin
	-- {
	-- 	"mfussenegger/nvim-dap",
	-- 	dependencies = {
	-- 		"rcarriga/nvim-dap-ui", -- UI for DAP
	-- 		"nvim-neotest/nvim-nio", -- Required by dap-ui
	-- 		"mfussenegger/nvim-dap-python", -- Python adapter
	-- 		"theHamsta/nvim-dap-virtual-text", -- Inline variable text
	-- 	},
	-- 	config = function()
	-- 		local dap = require("dap")
	-- 		local dapui = require("dapui")
	--
	-- 		-- Setup dap-ui
	-- 		dapui.setup()
	--
	-- 		-- Auto open/close dap-ui
	-- 		dap.listeners.after.event_initialized["dapui_config"] = function()
	-- 			dapui.open()
	-- 		end
	-- 		dap.listeners.before.event_terminated["dapui_config"] = function()
	-- 			dapui.close()
	-- 		end
	-- 		dap.listeners.before.event_exited["dapui_config"] = function()
	-- 			dapui.close()
	-- 		end
	--
	-- 		-- Keymaps
	-- 		-- Change the F-key ones to <leader>d...
	-- 		vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP Continue" })
	-- 		vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "DAP Step Over" })
	-- 		vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP Step Into" })
	-- 		vim.keymap.set("n", "<leader>du", dap.step_out, { desc = "DAP Step Out" })
	-- 		vim.keymap.set("n", "<leader>dui", dapui.toggle, { desc = "DAP UI Toggle" })
	-- 		vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint)
	-- 		vim.keymap.set("n", "<Leader>B", function()
	-- 			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
	-- 		end)
	--
	-- 		-- Virtual text
	-- 		require("nvim-dap-virtual-text").setup()
	-- 	end,
	-- },
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
		ft = { "markdown", "codecompanion" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {},
	},
	-- {
	-- 	-- Python-specific setup
	-- 	"mfussenegger/nvim-dap-python",
	-- 	config = function()
	-- 		local dap_python = require("dap-python")
	-- 		dap_python.setup("python") -- or full path to your venv python
	-- 		dap_python.test_runner = "pytest"
	-- 	end,
	-- },
	-- {
	-- 	"inhesrom/remote-ssh.nvim",
	-- 	branch = "master",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		-- "neovim/nvim-lspconfig",
	-- 	},
	-- 	config = function()
	-- 		-- setup lsp_config here or import from part of neovim config that sets up LSP
	-- 		require("remote-ssh").setup({})
	-- 	end,
	-- },

	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,

		config = function()
			vim.g.mkdp_auto_close = 0
		end,
	},
	{ "shortcuts/no-neck-pain.nvim" },
	{ "nullchilly/fsread.nvim" },
	{
		"mrcjkb/rustaceanvim",
		version = "^6", -- Recommended
		lazy = false, -- This plugin is already lazy

		config = function()
			vim.g.rustaceanvim = {
				server = {
					settings = {
						["rust-analyzer"] = {
							inlayHints = {
								bindingModeHints = { enable = true },
								chainingHints = { enable = true },
								closingBraceHints = { enable = true },
								parameterHints = { enable = true },
								typeHints = { enable = true },
							},
						},
					},
				},
			}
		end,
	},
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},

		opts = {
			interactions = {
				chat = {

					-- adapter = "gemini",
					adapter = "openai_responses",
					-- adapter = "openai",

					-- keymaps = {
					-- 	confirm = "<C-s>",
					-- },
				},
				inline = {
					-- 				adapter = "gemini",
					-- adapter = "openai",

					adapter = "openai_responses",
				},
			},

			adapters = {
				http = {},
			},
		},

		config = function(_, opts)
			require("custom.codecompanion").setup(opts)
		end,
		-- ...existing code...
		-- config = function(_, opts)
		-- 	-- opts.adapters.http.gemini = function()
		-- 	-- 	return require("codecompanion.adapters").extend("gemini", {
		-- 	-- 		env = {
		-- 	-- 			api_key = "...",
		-- 	-- 		},
		-- 	--
		-- 	-- 		schema = {
		-- 	-- 			model = {
		-- 	-- 				default = "gemini-3-flash-preview",
		-- 	-- 			},
		-- 	-- 		},
		-- 	-- 	})
		-- 	-- end
		-- 	opts.adapters.http.openai = function()
		-- 		return require("codecompanion.adapters").extend("openai", {
		-- 			env = {
		-- 				api_key = "",
		-- 				-- your OPENAI API key
		-- 			},
		--
		-- 			schema = {
		-- 				model = {
		-- 					-- default = "gpt-5.4-mini", -- or gpt-4.1 / gpt-4o
		-- 					default = "gpt-5", -- or gpt-4.1 / gpt-4o
		-- 				},
		-- 			},
		-- 		})
		-- 	end
		--
		-- 	require("codecompanion").setup(opts)
		-- end,
	},

	-- {
	-- 	"olimorris/codecompanion.nvim",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 	},
	-- 	opts = {
	-- 		log_level = "DEBUG",
	-- 		strategies = {
	-- 			chat = {
	-- 				adapter = "gemini",
	-- 			},
	-- 			inline = {
	-- 				adapter = "gemini",
	-- 			},
	-- 		},
	-- 		adapters = {
	-- 			http = {},
	-- 		},
	-- 	},
	-- 	config = function(_, opts)
	-- 		local function api_key()
	-- 			local handle = io.popen("gpg --quiet --decrypt ~/model_key.txt.gpg 2>/dev/null")
	-- 			if handle then
	-- 				local result = handle:read("*a")
	-- 				handle:close()
	-- 				-- trim whitespace/newlines
	-- 				return result:gsub("%s+$", "")
	-- 			end
	-- 			return nil
	-- 		end
	-- 		opts.adapters.http.gemini = function()
	-- 			return require("codecompanion.adapters").extend("gemini", {
	-- 				env = {
	-- 					api_key = api_key,
	-- 				},
	-- 			})
	-- 		end
	--
	-- 		require("codecompanion").setup(opts)
	-- 	end,
	-- },
}
