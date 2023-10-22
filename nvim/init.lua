-------------------------------------------------------------------------------
-- Ideas
-------------------------------------------------------------------------------
-- Remote github checkout:
--  - <leader>sghl brings up a telescope prompt that lets me search through Lazyvim github and check out any files I want

-------------------------------------------------------------------------------
-- Options
-------------------------------------------------------------------------------

vim.opt.signcolumn = "yes:2" -- always show the sign column, otherwise it would shift the text each time
vim.opt.mouse = "a" -- allow the mouse to be used in neovim. Particularly useful for resizing splits
vim.opt.mousemoveevent = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.foldmethod = "expr" -- folding set to "expr" for treesitter based folding
vim.opt.foldlevelstart = 99 -- open file with expanded folds
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- set for treesitter based folding
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.number = true -- show current line number
vim.opt.splitbelow = true -- force all horizontal splits to go below current window
vim.opt.splitright = true -- force all vertical splits to go to the right of current window
vim.opt.wrap = false -- display lines as one long line
vim.opt.ignorecase = true -- ignore case in search patterns
vim.opt.scrolloff = 8 -- minimal number of screen lines to keep above and below the cursor
vim.opt.sidescrolloff = 8 -- minimal number of screen columns to keep to the left and right of the cursor if wrap is `false`
vim.opt.pumheight = 10 -- pop up menu height
vim.opt.iskeyword:append("-") -- treats words with `-` as single words
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.opt.showcmd = true -- unset to hide (partial) command in the last line of the screen (for performance)
vim.opt.showmode = false -- no more modes like -- INSERT -- on the last line. The status line plugin (lualine) replaces this.
vim.opt.cursorline = true -- highlight the current line
vim.opt.whichwrap:append("<,>,[,],h,l") -- keys allowed to move to the previous/next line when the beginning/end of line is reached
vim.opt.confirm = true -- instead of failing on :q with unsaved changed, prompt user to confirm if they want to quit without saving

-- show special characters for tabs, trailing spaces, etc.
vim.opt.list = true
vim.opt.listchars = "tab:▸-◂,trail:·,precedes:◁,extends:▷"

vim.opt.swapfile = false -- do not create a swapfile
vim.opt.undofile = true -- enable persistent undo

vim.opt.expandtab = true -- convert tabs to spaces
vim.opt.tabstop = 2 -- insert 2 spaces for a tab
vim.opt.shiftwidth = 2 -- the number of spaces inserted for each indentation

-- Reduce time for writing to swap file and firing CursorHold when the cursor
-- isn't moving. This autocmd is used by various plugins for highlighting
vim.opt.updatetime = 300 -- faster completion (4000ms default)

-- vim.api.nvim_set_var("matchparen_timeout", 2)
-- vim.o.noshowmatch = true
vim.g.loaded_matchparen = 1
-- vim.g.matchparen_timeout = 2

-- Configure opam
-- set rtp^="/home/adler/.opam/cs3110-2021fa/share/ocp-indent/vim"

-------------------------------------------------------------------------------
-- Custom functions and autocommands
-------------------------------------------------------------------------------

--  Open shorthand github repositories in the browser, else do normal gx
--  Greatly helps with plugin management
vim.cmd([[
    function! BetterGX()
        let l:link = expand('<cfile>')
        if l:link =~ '^[^/]\+/[^/]\+$'
            let l:link = 'https://github.com/' . l:link
        endif
        call netrw#BrowseX(l:link, netrw#CheckIfRemote())
    endfunction
    noremap <silent> gx :call BetterGX()<CR>
]])

-- Enable spell checking for documents
vim.cmd([[
    autocmd FileType tex,text,markdown setlocal spell spelllang=en_us
]])

-- enable wrap mode for certain filetypes only
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.json", "*.jsonc", "*.md", "*.txt" },
	command = "setlocal wrap",
})

-------------------------------------------------------------------------------
-- Keymap
-------------------------------------------------------------------------------
local opts = { silent = true }

-- Remap space as leader key
vim.keymap.set("", "<space>", "<nop>", opts)
vim.g.mapleader = " "

-- Allow gf to open non-existent files
vim.keymap.set("n", "gf", ":edit <cfile><cr>", opts)

-- Reselect visual selection after indenting
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Switch buffers
vim.keymap.set("n", "H", ":bprevious<cr>", opts)
vim.keymap.set("n", "L", ":bnext<cr>", opts)

-- Switch windows
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)

-- Put-replace without copying
vim.keymap.set("v", "<leader>p", '"_dp', opts)

-------------------------------------------------------------------------------
-- A script that automatically closes untouched buffers
-------------------------------------------------------------------------------
local id = vim.api.nvim_create_augroup("startup", {
	clear = false,
})
local persistbuffer = function(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	vim.fn.setbufvar(bufnr, "bufpersist", 1)
end
vim.api.nvim_create_autocmd({ "BufRead" }, {
	group = id,
	pattern = { "*" },
	callback = function()
		vim.api.nvim_create_autocmd({ "InsertEnter", "BufModifiedSet" }, {
			buffer = 0,
			once = true,
			callback = function()
				persistbuffer()
			end,
		})
	end,
})
vim.keymap.set("n", "<leader>bb", function()
	local curbufnr = vim.api.nvim_get_current_buf()
	local buflist = vim.api.nvim_list_bufs()
	for _, bufnr in ipairs(buflist) do
		if vim.bo[bufnr].buflisted and bufnr ~= curbufnr and (vim.fn.getbufvar(bufnr, "bufpersist") ~= 1) then
			vim.cmd("bd " .. tostring(bufnr))
		end
	end
end, { silent = true, desc = "Close unused buffers" })

-------------------------------------------------------------------------------
-- Bootstrap package manager
-------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-------------------------------------------------------------------------------
-- Plugins
-------------------------------------------------------------------------------
require("lazy").setup({
	{
		"catppuccin/nvim",
		enabled = false,
		name = "catppuccin",
		lazy = false, -- load during startup
		priority = 1000, -- load before all other start plugins
		config = function()
			vim.opt.termguicolors = true -- set term gui colors (most terminals support this)
			vim.cmd.colorscheme("catppuccin-mocha") -- latte for light mode
		end,
	},
	{
		"folke/tokyonight.nvim",
		enabled = true,
		lazy = false, -- load during startup
		priority = 1000, -- load before all other start plugins
		config = function()
			vim.opt.termguicolors = true -- set term gui colors (most terminals support this)
			vim.cmd.colorscheme("tokyonight-night")
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 500
			local wk = require("which-key")
			wk.setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
				plugins = {
					marks = true, -- shows a list of your marks on ' and `
					registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
					spelling = {
						enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
						suggestions = 20, -- how many suggestions should be shown in the list?
					},
					presets = {
						operators = false,
						motions = false,
						text_objects = false,
					},
				},
			})
			wk.register({
				s = {
					name = "🔎Search", -- optional group name
					-- f = { "<cmd>Telescope find_files<cr>", "Find File" }, -- create a binding with label
					-- e = "Just a label", -- Just a label
					-- ["1"] = "which_key_ignore", -- special label to hide it in the popup
					-- b = { function() print("bar") end, "Foobar" }, -- you can also pass functions!
				},
				g = {
					name = "Git",
					t = { name = "Toggle" },
					d = { name = "Diffview" },
				},
				n = {
					name = "Neovim",
					c = { ":e ~/.config/nvim/init.lua<CR>", "Edit Config" },
				},
				t = { name = "Treesitter" },
				h = { "<cmd>noh<cr>", "No Highlight" },
				[","] = { "A,<esc>", "Trailing Comma" },
				[";"] = { "A;<esc>", "Trailing Semi" },
				p = {
					name = "Plugins",
					i = { "<cmd>Lazy install<cr>", "Install" },
					s = { "<cmd>Lazy sync<cr>", "Sync" },
					S = { "<cmd>Lazy clear<cr>", "Status" },
					c = { "<cmd>Lazy clean<cr>", "Clean" },
					u = { "<cmd>Lazy update<cr>", "Update" },
					p = { "<cmd>Lazy profile<cr>", "Profile" },
					l = { "<cmd>Lazy log<cr>", "Log" },
					d = { "<cmd>Lazy debug<cr>", "Debug" },
				},
				b = {
					name = "Buffers",
					j = { "<cmd>BufferLinePick<cr>", "Jump" },
					f = { "<cmd>Telescope buffers previewer=false<cr>", "Find" },
					-- b = { "<cmd>BufferLineCyclePrev<cr>", "Previous" },
					n = { "<cmd>BufferLineCycleNext<cr>", "Next" },
					W = { "<cmd>noautocmd w<cr>", "Save without formatting (noautocmd)" },
					-- w = { "<cmd>BufferWipeout<cr>", "Wipeout" }, -- TODO: implement this for bufferline
					e = {
						"<cmd>BufferLinePickClose<cr>",
						"Pick which buffer to close",
					},
					h = { "<cmd>BufferLineCloseLeft<cr>", "Close all to the left" },
					l = {
						"<cmd>BufferLineCloseRight<cr>",
						"Close all to the right",
					},
					D = {
						"<cmd>BufferLineSortByDirectory<cr>",
						"Sort by directory",
					},
					L = {
						"<cmd>BufferLineSortByExtension<cr>",
						"Sort by language",
					},
				},
				d = {
					name = "Debug",
					t = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle Breakpoint" },
					b = { "<cmd>lua require'dap'.step_back()<cr>", "Step Back" },
					c = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
					C = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To Cursor" },
					d = { "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect" },
					g = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
					i = { "<cmd>lua require'dap'.step_into()<cr>", "Step Into" },
					o = { "<cmd>lua require'dap'.step_over()<cr>", "Step Over" },
					u = { "<cmd>lua require'dap'.step_out()<cr>", "Step Out" },
					p = { "<cmd>lua require'dap'.pause()<cr>", "Pause" },
					r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Toggle Repl" },
					s = { "<cmd>lua require'dap'.continue()<cr>", "Start" },
					q = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
					U = { "<cmd>lua require'dapui'.toggle({reset = true})<cr>", "Toggle UI" },
				},
				l = {
					name = "LSP",
					f = { name = "Format" },
				},
			}, { prefix = "<leader>" })
		end,
	},
	{
		"dstein64/vim-startuptime",
		-- lazy-load on a command
		cmd = "StartupTime",
	},
	{
		"max397574/better-escape.nvim",
		opts = {
			mapping = { "kj" },
		},
	},
	{
		-- TODO: customize
		"nvim-lualine/lualine.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = true,
	},
	{
		-- TODO: customize
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{ "<leader>e", "<CMD>Neotree toggle reveal_force_cwd<CR>", desc = "Explorer", mode = { "n", "v" } },
		},
		config = true,
	},
	{ "ethanholz/nvim-lastplace", config = true },
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"BurntSushi/ripgrep",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = false },
		},
		cmd = "Telescope",
		keys = {
			{ "<leader>sa", "<CMD>Telescope<CR>", desc = "Anything", mode = { "n", "v" } },
			{ "<leader>sp", "<CMD>Telescope resume<CR>", desc = "Previous search", mode = { "n", "v" } },
			{
				"<leader>sf",
				"<CMD> Telescope find_files follow=true no_ignore=true hidden=true <CR>",
				desc = "All files",
				mode = { "n", "v" },
			},
			{ "<leader>f", "<CMD>Telescope find_files<CR>", desc = "Search file", mode = { "n", "v" } },
			{ "<leader>st", "<CMD>Telescope live_grep<CR>", desc = "Text", mode = { "n", "v" } },
			{ "<leader>sw", "<CMD>Telescope grep_string<CR>", desc = "Word under cursor", mode = { "n", "v" } },
			{ "<leader>sk", "<CMD>Telescope keymaps<CR>", desc = "Keymap", mode = { "n", "v" } },
			{ "<leader>sh", "<CMD>Telescope help_tags<CR>", desc = "Help", mode = { "n", "v" } },
		},
		opts = {
			defaults = {
				wrap_results = true,
				prompt_prefix = "🥴🔭> ",
				file_ignore_patterns = { ".git/", "node_modules/" },
			},
			pickers = {
				find_files = { hidden = true },
				git_files = { show_untracked = true },
			},
		},
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)
			telescope.load_extension("fzf")
		end,
	},
	{
		"folke/neodev.nvim",
		-- TODO: is this working properly?
		opts = {},
		config = function(self, opts)
			require("neodev").setup({
				library = { plugins = { "nvim-dap-ui" }, types = true },
			})
		end,
	},
	{
		"VonHeikemen/lsp-zero.nvim",
		event = { "BufReadPost", "BufNewFile" },
		branch = "v1.x",
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig", dependencies = { "folke/neodev.nvim" } },
			"williamboman/mason-lspconfig.nvim",
			{ "williamboman/mason.nvim", build = ":MasonUpdate", cmd = { "Mason", "MasonUpdate" } },

			-- Setup null-ls
			"jay-babu/mason-null-ls.nvim",
			"jose-elias-alvarez/null-ls.nvim",

			-- Autocompletion
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lua",

			-- Snippets
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local lsp = require("lsp-zero")
			lsp.preset({ name = "recommended" })

			-- Configure lua language server for neovim
			lsp.nvim_workspace()
			lsp.setup()
			vim.diagnostic.config({ virtual_text = true })

			-- Setup null-ls
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					-- Replace these with the tools you want to install
					null_ls.builtins.diagnostics.eslint,
				},
			})

			-- See mason-null-ls.nvim's documentation for more details:
			-- https://github.com/jay-babu/mason-null-ls.nvim#setup
			require("mason-null-ls").setup({
				-- ensure_installed = { 'stylua', 'eslint', 'prettierd' },
				ensure_installed = nil,
				automatic_installation = true,
				-- removes the need to configure null-ls for supported sources
				-- sources found in mason will automatically be setup for null-ls
				automatic_setup = true,
			})

			-- Override lsp-zero cmp configs
			local cmp = require("cmp")
			cmp.setup({
				-- TODO: enter to insert, ctrl-enter to replace
				preselect = cmp.PreselectMode.None,
				completion = {
					completeopt = "menu, meunone, noselect",
					-- Override trigger characters to ignore closing tag: see https://github.com/hrsh7th/nvim-cmp/issues/1055
					get_trigger_characters = function(trigger_characters)
						local new_trigger_characters = {}
						for _, char in ipairs(trigger_characters) do
							if char ~= ">" then
								table.insert(new_trigger_characters, char)
							end
						end
						return new_trigger_characters
					end,
				},
				experimental = {
					ghost_text = { hl_group = "LspCodeLens" },
				},

				-- Try some performance tuning. Nvim-cmp could use some optimizations. If I have free time I might take a look
				-- See https://github.com/hrsh7th/nvim-cmp/issues/1009
				-- performance = {
				--   debounce = 500, -- time to wait to trigger completion
				--   throttle = 550,
				--   fetching_timeout = 80,
				-- },
				-- anotherworarondforthesame issue as above with tailwind LS
				-- sources = {
				--   name = "nvim_lsp",
				--   max_item_count = 200,
				-- },
			})
		end,
		keys = {
			{ "gD", ":lua vim.lsp.buf.declaration()<CR>", desc = "Go to declaration" },
			{ "gd", ":lua vim.lsp.buf.definition()<CR>", desc = "Go to definition" },
			{ "gi", ":lua vim.lsp.buf.implementation()<CR>", desc = "Go to implementation" },
			{ "gr", ":lua vim.lsp.buf.references()<CR>", desc = "Go to references" },
			{ "gT", ":lua vim.lsp.buf.type_definition()<CR>", desc = "Go to type definition" },
			{ "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
			{ "<leader>ld", "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", desc = "Buffer Diagnostics" },
			{ "<leader>lw", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
			{ "<leader>lff", "<cmd>lua vim.lsp.buf.format()<cr>", desc = "Format with LSP" },
			{ "<leader>li", "<cmd>LspInfo<cr>", desc = "Info" },
			{ "<leader>lI", "<cmd>Mason<cr>", desc = "Mason Info" },
			{ "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "Next Diagnostic" },
			{ "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "Prev Diagnostic" },
			{ "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "CodeLens Action" },
			{ "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Quickfix" },
			{ "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
			{ "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
			{ "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace Symbols" },
			{ "<leader>le", "<cmd>Telescope quickfix<cr>", desc = "Telescope Quickfix" },
		},
	},
	{
		"elentok/format-on-save.nvim",
		keys = {
			{ "<leader>lfd", "<cmd>FormatOff<cr>", desc = "Disable format on save" },
			{ "<leader>lfe", "<cmd>FormatOn<cr>", desc = "Enable format on save" },
		},
		lazy = false,
		config = function()
			local format_on_save = require("format-on-save")
			local formatters = require("format-on-save.formatters")

			-- Check if the buffer file is in a project using prettier
			local function prettier_project()
				-- Search for a package.json file in the current dir or its parents
				local package_json = vim.fn.findfile("package.json", ".;")
				if not package_json then
					return nil
				end
				-- Is prettier installed in package.json?
				local file = io.open(package_json, "r")
				if not file then
					return nil
				end
				local content = file:read("*a")
				file:close()
				return string.match(content, "prettier") ~= nil
			end

			---@type ErrorNotifier test
			local error_notifier = {
				show = function(opts)
					-- use opts.title and opts.body
				end,
				hide = function()
					-- hide the error when it's been resolved
				end,
			}

			format_on_save.setup({
				exclude_path_patterns = {
					"/node_modules/",
					".local/share/nvim/lazy",
				},
				-- disable annoying vim.notify() error notification
				error_notifier = error_notifier,
				formatter_by_ft = {
					lua = formatters.stylua,
					rust = formatters.lsp,
					sh = formatters.shfmt,
					-- Concatenate formatters
					python = {
						formatters.remove_trailing_whitespace,
						-- formatters.shell({ cmd = "tidy-imports" }),
						formatters.black,
					},
				},
				-- fallback formatter to use when no formatters match the current filetype
				fallback_formatter = function()
					if prettier_project() then
						-- vim.notify("Formatting with Prettier")
						return formatters.prettierd
					else
						-- vim.notify("Formatting with LSP")
						return formatters.lsp()
					end
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		enabled = true,
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{
				"HiPhish/rainbow-delimiters.nvim",
				lazy = false,
				enabled = false,
				opts = function()
					return {
						-- Highlight the entire buffer at once if it's a small buffer
						strategy = {
							[""] = function()
								-- only enable rainbow delimiters in small files
								local buf = vim.api.nvim_get_current_buf()
								local line_count = vim.api.nvim_buf_line_count(buf)
								if line_count < 3000 then
									return require("rainbow-delimiters").strategy.global
								end
							end,
						},
						-- Which query to use for finding delimiters based on ft
						query = {
							[""] = "rainbow-delimiters",
							-- tsx = "rainbow-parens",
							tsx = "rainbow-delimiters-react",
						},
					}
				end,
				config = function(_, opts)
					require("rainbow-delimiters.setup")(opts)
				end,
			},
			"nvim-treesitter/playground",
			"JoosepAlviste/nvim-ts-context-commentstring",
			{
				"nvim-treesitter/nvim-treesitter-context",
				keys = {
					{ "<leader>tsc", "<cmd>TSContextToggle<cr>", desc = "Toggle TS Context" },
					{
						"[c",
						"<cmd>lua require('treesitter-context').go_to_context()<cr>",
						desc = "Go to context",
						mode = { "n" },
					},
				},
				cmd = { "TSContextEnable", "TSContextDisable", "TSContextToggle" },
				opts = {
					max_lines = 3,
				},
				config = true,
			},
		},
		keys = {
			{ "<leader>ts", "<CMD>TSPlaygroundToggle<CR>", desc = "Playground", mode = { "n", "v" } },
			{ "<c-space>", desc = "Increment selection" },
			{ "<bs>", desc = "Decrement selection", mode = { "x" } },
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				-- A list of parser names, or "all"
				ensure_installed = "all",
				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = false,
				-- Automatically install missing parsers when entering buffer
				auto_install = true,

				highlight = {
					enable = true,
					-- disable slow treesitter highlight for large files
					disable = function(lang, buf)
						local max_filesize = 20 * 1024 -- 20 KB
						local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,
				},
				indent = { enable = true },
				-- disable the default autocmd via the context_commentstring Integrations guide:
				-- https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations#nvim-comment
				context_commentstring = { enable = true, enable_autocmd = false },

				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<c-space>",
						node_incremental = "<c-space>",
						scope_incremental = "<nop>",
						node_decremental = "<bs>",
					},
				},

				playground = {
					enable = true,
					disable = {},
					updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
					persist_queries = false, -- Whether the query persists across vim sessions
					keybindings = {
						toggle_query_editor = "o",
						toggle_hl_groups = "i",
						toggle_injected_languages = "t",
						toggle_anonymous_nodes = "a",
						toggle_language_display = "I",
						focus_language = "f",
						unfocus_language = "F",
						update = "R",
						goto_node = "<cr>",
						show_help = "?",
					},
				},
			})
		end,
	},
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")
			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					pythonPath = function()
						return "/usr/bin/python"
					end,
				},
			}
			-- Automatically read VSCode launch.json
			require("dap.ext.vscode").load_launchjs(nil, {
				["pwa-node"] = {
					"javascript",
					"typescript",
				},
				["node"] = {
					"javascript",
					"typescript",
				},
			})
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},
	{
		"mxsdev/nvim-dap-vscode-js",
		dependencies = {
			"mfussenegger/nvim-dap",
			"rcarriga/nvim-dap-ui",
			{
				"microsoft/vscode-js-debug",
				build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
			},
		},
		ft = { "javascript", "typescript" },
		config = function()
			local _, lazy_config = pcall(require, "lazy.core.config")
			local debugger_path = lazy_config.defaults.root .. "/" .. "vscode-js-debug"
			require("dap-vscode-js").setup({
				-- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
				debugger_path = debugger_path,
				-- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
				adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
				-- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
				-- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
				-- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
			})
			for _, language in ipairs({ "typescript", "javascript" }) do
				require("dap").configurations[language] = {
					{
						address = "0.0.0.0",
						localRoot = "${workspaceFolder}",
						name = "Attach to Docker",
						port = 9229,
						remoteRoot = "/app",
						request = "attach",
						skipFiles = { "<node_internals>/**" },
						type = "pwa-node",
						restart = "true",
					},
					{
						type = "server",
						host = "0.0.0.0",
						port = "9229",
					},
				}
			end
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			-- If you want insert `(` after select function or method item
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

			local Rule = require("nvim-autopairs.rule")
			local npairs = require("nvim-autopairs")
			require("nvim-autopairs").setup()

			npairs.add_rules({
				Rule('"""', '"""', { "graphql" }),
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = true,
	},
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	},
	{
		"terrortylor/nvim-comment",
		keys = {
			{ "<leader>/", "<CMD>CommentToggle<CR>", desc = "Comment Line", mode = { "n" } },
			{ "<leader>/", ":'<,'>CommentToggle<CR>gv<esc>", desc = "Comment Block", mode = { "v" } },
		},
		config = function()
			require("nvim_comment").setup({
				hook = function()
					require("ts_context_commentstring.internal").update_commentstring()
				end,
			})
		end,
	},
	{
		"fedepujol/move.nvim",
		keys = {
			{ "<A-j>", ":MoveLine(1)<CR>", mode = { "n" } },
			{ "<A-k>", ":MoveLine(-1)<CR>", mode = { "n" } },
			{ "<A-j>", ":MoveBlock(1)<CR>", mode = { "v" } },
			{ "<A-k>", ":MoveBlock(-1)<CR>", mode = { "v" } },
		},
	},
	{
		"akinsho/toggleterm.nvim",
		keys = {
			{ "<C-t>", ":ToggleTerm<CR>" },
			{ "<C-t>", "<C-\\><C-n>:ToggleTerm<CR>", mode = { "t" } },
		},
		opts = { direction = "float" },
	},
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		ft = "markdown",
		keys = {
			{ "<leader>m", ":MarkdownPreviewToggle<CR>", desc = "Markdown Preview", mode = { "n" } },
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]h", function()
						if vim.wo.diff then
							return "]h"
						end
						vim.schedule(function()
							gs.next_hunk()
						end)
						return "<Ignore>"
					end, { expr = true })

					map("n", "[h", function()
						if vim.wo.diff then
							return "[h"
						end
						vim.schedule(function()
							gs.prev_hunk()
						end)
						return "<Ignore>"
					end, { expr = true })

					-- Actions
					map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", { desc = "Stage Hunk" })
					map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset Hunk" })
					map("n", "<leader>gS", ":Gitsigns stage_buffer<CR>", { desc = "Stage Buffer" })
					map("n", "<leader>gu", ":Gitsigns undo_stage_hunk<CR>", { desc = "Undo Stage Hunk" })
					map("n", "<leader>gR", ":Gitsigns reset_buffer<CR>", { desc = "Reset Buffer" })
					map("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview Hunk" })
					map("n", "<leader>gb", function()
						gs.blame_line({ full = true })
					end, { desc = "Blame Line" })
					map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "Toggle Blame" })
					map("n", "<leader>gd", gs.diffthis, { desc = "Diff This" })
					map("n", "<leader>gD", function()
						gs.diffthis("~")
					end, { desc = "Diff This (~) ??" })
					map("n", "<leader>gtd", gs.toggle_deleted, { desc = "Toggle Deleted" })

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
				end,
			})
		end,
	},
	{
		"cshuaimin/ssr.nvim",
		module = "ssr",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		-- Calling setup is optional.
		config = function()
			require("ssr").setup({
				border = "rounded",
				min_width = 50,
				min_height = 5,
				max_width = 120,
				max_height = 25,
				keymaps = {
					close = "q",
					next_match = "n",
					prev_match = "N",
					replace_confirm = "<cr>",
					replace_all = "<leader><cr>",
				},
			})
		end,
		keys = {
			{
				"<leader>tr",
				function()
					require("ssr").open()
				end,
				desc = "Structural Replace",
				mode = { "n", "x" },
			},
		},
	},
	{
		"folke/zen-mode.nvim",
		dependencies = {
			"folke/twilight.nvim",
		},
		-- if 'config' is omitted, 'opts' gets passed into require(plugin).setup()
		-- config may be a function that returns a table
		-- if opts is set then it gets passed into config = function(_, opts) so you can use the opts later
		opts = {
			plugins = {
				twilight = { enabled = false }, -- highlight only active portions of code
				gitsigns = { enabled = false }, -- disables git signs
				tmux = { enabled = true }, -- disables the tmux statusline
				kitty = { enabled = true, font = "+4" }, -- increase font size
			},
		},
		keys = {
			{ "<leader>z", "<CMD>ZenMode<CR>", desc = "Zen mode" },
		},
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = {
			options = {
				-- separator_style = "slant",
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(num, _, diagnostics, _)
					local result = {}
					local symbols = {
						error = "",
						warning = "",
						info = "",
					}
					for name, count in pairs(diagnostics) do
						if symbols[name] and count > 0 then
							table.insert(result, symbols[name] .. " " .. count)
						end
					end
					local result_str = table.concat(result, " ")
					return #result > 0 and result_str or ""
				end,
				hover = {
					enabled = true,
					delay = 50,
					reveal = { "close" },
				},
				groups = {
					options = {
						toggle_hidden_on_enter = true, -- when you re-enter a hidden group this options re-opens that group so the buffer is visible
					},
					items = {
						-- {
						--   name = "Backend",
						--   matcher = function(buf)
						--     -- Search for a Tauri project file in the current dir or its parents
						--     local tauri_file = vim.fn.findfile("tauri.conf.json", ".;")
						--     if tauri_file == "" then
						--       return false
						--     end
						--
						--     -- Get the Tauri project's root directory
						--     local tauri_src_dir = vim.fn.fnamemodify(tauri_file, ":h") -- parent dir
						--     local project_dir = vim.fn.fnamemodify(tauri_src_dir, ":h") -- grandparent dir
						--     local project_dir_escaped = project_dir:gsub("(%W)", "%%%1")
						--
						--     -- get the absolute path of the buffer's file
						--     local buf_path = vim.fn.bufname(buf.id)
						--     -- get the path to the buffile from the project root
						--     local buf_path_from_project = buf_path:gsub(project_dir_escaped, "")
						--
						--     return buf_path_from_project:match("src%-tauri/") ~= nil
						--   end,
						-- },
						-- {
						--   name = "Frontend",
						--   matcher = function(buf)
						--     -- Search for a Tauri project file in the current dir or its parents
						--     local tauri_file = vim.fn.findfile("tauri.conf.json", ".;")
						--     if tauri_file == "" then
						--       return false
						--     end
						--
						--     -- Get the Tauri project's root directory
						--     local tauri_src_dir = vim.fn.fnamemodify(tauri_file, ":h") -- parent dir
						--     local project_dir = vim.fn.fnamemodify(tauri_src_dir, ":h") -- grandparent dir
						--     local project_dir_escaped = project_dir:gsub("(%W)", "%%%1")
						--
						--     -- get the absolute path of the buffer's file
						--     local buf_path = vim.fn.bufname(buf.id)
						--     -- get the path to the buffile from the project root
						--     local buf_path_from_project = buf_path:gsub(project_dir_escaped, "")
						--
						--     return buf_path_from_project:match("src/") ~= nil and buf_path_from_project:match("src%-tauri/") == nil
						--   end,
						-- }
					},
				},
			},
		},
	},
	{
		"NvChad/nvim-colorizer.lua",
		opts = {
			filetypes = {
				"*", -- highlight all files but customize some others
				cmp_docs = { always_update = true },
			},
			user_default_options = {
				tailwind = true,
			},
		},
	},
	{ "christoomey/vim-tmux-navigator" },
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {},
		-- stylua: ignore
		keys = {
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
			{ "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
			{ "r", mode = "o",               function() require("flash").remote() end,     desc = "Remote Flash" },
			{
				"R",
				mode = { "o", "x" },
				function() require("flash").treesitter_search() end,
				desc =
				"Treesitter Search"
			},
			{
				"<c-s>",
				mode = { "c" },
				function() require("flash").toggle() end,
				desc =
				"Toggle Flash Search"
			},
		},
	},
	{
		"j-hui/fidget.nvim",
		tag = "legacy",
		event = "LspAttach",
		config = true,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		enabled = false,
		opts = {
			-- show_current_context = true,
			-- show_current_context_start = true
		},
	},
	{
		"JellyApple102/easyread.nvim",
		ft = "text",
		config = true,
	},
	{
		"nmac427/guess-indent.nvim",
		lazy = false,
		config = true,
	},
	{
		"LunarVim/bigfile.nvim",
		lazy = false,
		config = true,
	},
	{
		"stevearc/dressing.nvim",
		opts = {},
		event = "VeryLazy",
	},
	-- TODO: setup
	{
		"sindrets/diffview.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "TimUntersberger/neogit", opts = { disable_commit_confirmation = true } },
		},
		keys = {
			{ "<leader>gdd", "<CMD>DiffviewOpen<CR>", mode = { "n", "v" }, desc = "Open" },
			{ "<leader>gdc", "<CMD>DiffviewClose<CR>", mode = { "n", "v" }, desc = "Close" },
		},
		config = true,
		-- config = {
		--   keymaps = {
		--     view = {
		--       ["<C-g>"] = "<CMD>DiffviewClose<CR>",
		--       ["c"] = "<CMD>DiffviewClose|Neogit commit<CR>",
		--     },
		--     file_panel = {
		--       ["<C-g>"] = "<CMD>DiffviewClose<CR>",
		--       ["c"] = "<CMD>DiffviewClose|Neogit commit<CR>",
		--     },
		--   },
		-- }
	},
})
