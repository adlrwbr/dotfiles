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

vim.opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.opt.foldlevelstart = 99 -- open file with expanded folds
vim.opt.foldenable = true

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
vim.opt.listchars = "tab:▸ ◂,trail:·,precedes:◁,extends:▷"

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
-- vim.g.loaded_matchparen = 1 -- explicitly disable match paren
-- vim.g.matchparen_timeout = 2
vim.api.nvim_set_var("cmdheight", 1)

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

-- Fix comment autoindentation in Python files [StackOverflow](https://stackoverflow.com/questions/2360249/vim-automatically-removes-indentation-on-python-comments)
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.py" },
	command = "setlocal nosmartindent",
})

-- Set harmony filetype and commentstring
vim.filetype.add({
	extension = {
		hny = "harmony",
	},
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = "*.hny",
	callback = function()
		vim.api.nvim_buf_set_option(0, "commentstring", "# %s")
	end,
})

vim.filetype.add({
	extension = {
		typ = "typst",
	},
})

-------------------------------------------------------------------------------
-- Keymap
-------------------------------------------------------------------------------
local key_opts = { silent = true }

-- Remap space as leader key
vim.keymap.set("", "<space>", "<nop>", key_opts)
vim.g.mapleader = " "

-- Allow gf to open non-existent files
vim.keymap.set("n", "gf", ":edit <cfile><cr>", key_opts)

-- Reselect visual selection after indenting
vim.keymap.set("v", "<", "<gv", key_opts)
vim.keymap.set("v", ">", ">gv", key_opts)

-- Switch buffers
vim.keymap.set("n", "H", ":bprevious<cr>", key_opts)
vim.keymap.set("n", "L", ":bnext<cr>", key_opts)

-- Switch windows
vim.keymap.set("n", "<C-l>", "<C-w>l", key_opts)
vim.keymap.set("n", "<C-h>", "<C-w>h", key_opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", key_opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", key_opts)

-- Put-replace without copying
vim.keymap.set("v", "<leader>p", '"_dp', key_opts)

-- By default C-d is "De-Tab" and C-t is "Tab". I prefer shift-tab
vim.keymap.set("i", "<S-Tab>", "<C-d>", key_opts)

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
					marks = false, -- shows a list of your marks on ' and `
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
					c = { name = "Git Conflict" },
				},
				c = { ":clo<CR>", "Close window" },
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
					c = { "<cmd>bdelete<cr>", "Close" },
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
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{
				"<leader>e",
				"<CMD>Neotree toggle reveal_force_cwd position=right<CR>",
				desc = "Explorer",
				mode = { "n", "v" },
			},
		},
		opts = {
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = false,
				},
			},
		},
		config = true,
	},
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig", "VonHeikemen/lsp-zero.nvim" },
		opts = {},
	},
	{
		"itchyny/vim-cursorword",
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
			{
				"<leader>sg",
				function()
					local pickers = require("telescope.pickers")
					local finders = require("telescope.finders")
					local conf = require("telescope.config").values
					list = vim.fn.systemlist("git diff --name-only main")

					pickers
						.new(opts, {
							prompt_title = "git diff",
							finder = finders.new_table({ results = list }),
							sorter = conf.generic_sorter(opts),
						})
						:find()
				end,
				desc = "Git files",
				mode = { "n", "v" },
			},
			{ "<leader>f", "<CMD>Telescope find_files<CR>", desc = "Search file", mode = { "n", "v" } },
			{ "<leader>st", "<CMD>Telescope live_grep<CR>", desc = "Text", mode = { "n", "v" } },
			{
				"<leader>sb",
				"<CMD>Telescope current_buffer_fuzzy_find<CR>",
				desc = "Search buffer",
				mode = { "n", "v" },
			},
			{ "<leader>sw", "<CMD>Telescope grep_string<CR>", desc = "Word under cursor", mode = { "n", "v" } },
			{ "<leader>sk", "<CMD>Telescope keymaps<CR>", desc = "Keymap", mode = { "n", "v" } },
			{ "<leader>sh", "<CMD>Telescope help_tags<CR>", desc = "Help", mode = { "n", "v" } },
			-- { "'", "<CMD>Telescope marks default_text=^<CR>", noremap = true, silent = true },
			-- { "`", "<CMD>Telescope marks default_text=^<CR>", noremap = true, silent = true },
		},
		opts = {
			defaults = {
				wrap_results = true,
				prompt_prefix = " 🥴🔭> ",
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
		config = function()
			require("neodev").setup({
				library = { plugins = { "nvim-dap-ui" }, types = true },
			})
		end,
	},
	{
		"VonHeikemen/lsp-zero.nvim",
		event = { "BufReadPost", "BufNewFile" },
		branch = "v3.x",
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig", dependencies = { "folke/neodev.nvim" } },

			-- Manage LSP Servers from neovim
			{ "williamboman/mason.nvim", build = ":MasonUpdate", cmd = { "Mason", "MasonUpdate" } },

			-- Automatically set up LSP servers installed via Mason
			"williamboman/mason-lspconfig.nvim",

			-- Automatically set up NullLS sources installed via Mason
			"jay-babu/mason-null-ls.nvim",
			-- Set up null-ls
			"nvimtools/none-ls.nvim", -- an actively maintained fork of null-ls

			-- Autocompletion
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lua",
			{
				"zbirenbaum/copilot-cmp",
				dependencies = "zbirenbaum/copilot.lua",
				opts = {},
			},

			-- Snippets
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local lsp_zero = require("lsp-zero")
			lsp_zero.preset({ name = "recommended" })

			vim.diagnostic.config({ virtual_text = true })

			require("mason").setup({})
			require("mason-lspconfig").setup({
				ensure_installed = { "texlab" },
				handlers = {
					lsp_zero.default_setup,
					-- Via [lsp-zero docs](https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/lsp.md#configure-language-servers)
					-- Configure the clangd language server (I was getting an "multiple offset encoding" error when trying to lsp hover in C)
					["clangd"] = function()
						require("lspconfig").clangd.setup({
							cmd = { "clangd", "--offset-encoding=utf-16" },
						})
					end,
					["lua_ls"] = function()
						-- Configure lua language server for neovim
						require("lspconfig").lua_ls.setup({
							settings = {
								Lua = {
									diagnostics = {
										-- force the language server to recognize the `vim` global
										globals = { "vim" },
									},
									workspace = {
										-- Disbale LuaLS prompt for standalone files: https://github.com/LunarVim/LunarVim/issues/4049#issuecomment-1634539474
										checkThirdParty = false,
									},
								},
							},
						})
					end,
					["yamlls"] = function()
						local capabilities = vim.lsp.protocol.make_client_capabilities()
						capabilities.textDocument.foldingRange = {
							dynamicRegistration = false,
							lineFoldingOnly = true,
						}
						require("lspconfig").yamlls.setup({
							capabilities = capabilities,
							settings = {
								yaml = {
									schemas = {
										kubernetes = "/*.yaml",
										["https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/schemas/json/github-workflow.json"] = {
											"**/.github/workflows/*.yml",
											"**/.github/workflows/*.yaml",
										},
										-- Add the schema for gitlab piplines
										-- ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = "*.gitlab-ci.yml",
									},
								},
							},
						})
					end,
				},
			})

			-- Setup null-ls
			local null_ls = require("null-ls")
			null_ls.setup()

			-- Automatically set up null_ls sources
			-- See mason-null-ls.nvim's documentation for more details:
			-- https://github.com/jay-babu/mason-null-ls.nvim#setup
			require("mason-null-ls").setup({
				ensure_installed = nil, -- primary source of truth is null_ls
				automatic_installation = true,
				-- an empty handlers will cause all sources from Mason to be automatically registered in null-ls
				-- removes the need to configure null-ls for supported sources
				handlers = {},
			})

			-- Extend lsp-zero cmp configs
			local cmp = require("cmp")
			local cmp_action = require("lsp-zero").cmp_action()
			local cmp_format = require("lsp-zero").cmp_format()
			-- `/` cmdline setup.
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
			-- `:` cmdline setup.
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			})
			require("luasnip.loaders.from_vscode").lazy_load()
			cmp.setup({
				-- TODO: enter to insert, ctrl-enter to replace
				preselect = cmp.PreselectMode.None,
				sources = {
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "buffer" },
					{ name = "nvim_lua" },
					{ name = "luasnip" },
					{ name = "copilot" },
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				formatting = cmp_format,
				completion = {
					completeopt = "menu, meunone, noselect, preview",
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
				-- extend default mappings
				mapping = cmp.mapping.preset.insert({
					-- `Enter` key to confirm completion
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					-- Ctrl+Space to trigger completion menu
					["<C-Space>"] = cmp.mapping.complete(),
					-- Navigate between snippet placeholder
					["<A-l>"] = cmp_action.luasnip_jump_forward(),
					["<A-h>"] = cmp_action.luasnip_jump_backward(),
					-- Scroll up and down in the completion documentation
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
				}),
			})
		end,
		keys = {
			{ "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "Next Diagnostic" },
			{ "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "Prev Diagnostic" },
			{ "<leader>ld", "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "Prev Diagnostic" },
			{ "K", "<cmd>lua vim.lsp.buf.hover()<cr>", desc = "Prev Diagnostic" },
			{ "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", desc = "Go to definition" },
			{ "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", desc = "Go to declaration" },
			{ "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", desc = "Go to implementation" },
			{ "gr", "<cmd>lua vim.lsp.buf.references()<CR>", desc = "Go to references" },
			{ "gT", "<cmd>lua vim.lsp.buf.type_definition()<CR>", desc = "Go to type definition" },
			{ "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", desc = "Get signature help" },
			{
				"<C-s>",
				"<cmd>lua vim.lsp.buf.signature_help()<cr>",
				mode = { "i" },
				desc = "Get signature help",
			},
			{ "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
			{ "<leader>lw", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
			{ "<leader>lff", "<cmd>lua vim.lsp.buf.format()<cr>", desc = "Format with LSP" },
			{ "<leader>li", "<cmd>LspInfo<cr>", desc = "Info" },
			{ "<leader>lI", "<cmd>Mason<cr>", desc = "Mason Info" },
			{ "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "CodeLens Action" },
			{ "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Quickfix" },
			{ "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
			{ "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
			{ "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace Symbols" },
			{ "<leader>le", "<cmd>Telescope quickfix<cr>", desc = "Telescope Quickfix" },
		},
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "FormatDisable", "FormatEnable", "ConformInfo", "Conform" },
		keys = {
			{ "<leader>lfi", "<cmd>ConformInfo<cr>", desc = "Formatter info" },
			{ "<leader>lfl", ":h conform-formatters<cr>", desc = "Formatter list" },
			{ "<leader>lfd", "<cmd>FormatDisable<cr>", desc = "Disable format on save" },
			{ "<leader>lfe", "<cmd>FormatEnable<cr>", desc = "Enable format on save" },
		},
		opts = {
			notify_on_error = false, -- Disable the error notification
			formatters_by_ft = { -- See `:h conform-formatters` for a list of supported formatters
				lua = { "stylua" },
				-- Conform runs multiple formatters sequentially
				python = { "isort", "black" },
				-- Use a sub-list to run only the first available formatter
				javascript = { { "prettierd", "prettier" } },
				javascriptreact = { { "prettierd", "prettier" } },
				typescript = { { "prettierd", "prettier" } },
				typescriptreact = { { "prettierd", "prettier" } },
				-- typescript = { { "biome-check", "prettier" } }, -- prettierd is messing up utility types like Omit and Pick
				-- typescriptreact = { { "biome-check", "prettier" } },
				sh = { "shfmt" },
				rust = { "rustfmt" }, -- When I develop w rust, I usually use rust-analyzer, which executes `cargo fmt`. The LSP is not available when injected in markdown, though, so I'm specifying the ft here.
				-- Use treesitter to format fenced code blocks
				markdown = { "injected" },
			},
			formatters = {
				rustfmt = {
					-- you can override formatter options here
					args = { "--edition", "2021" },
				},
			},
			format_on_save = function(bufnr)
				-- Disable with a global or buffer-local variable
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				-- Disable autoformat for files in a certain path
				local bufname = vim.api.nvim_buf_get_name(bufnr)
				if bufname:match("/node_modules/") then
					return
				end
				-- These options will be passed to conform.format()
				return { timeout_ms = 500, lsp_fallback = true }
			end,
		},
		config = function(_, opts)
			require("conform").setup(opts)
			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					-- FormatDisable! will disable formatting just for this buffer
					vim.b.disable_autoformat = true
				else
					vim.g.disable_autoformat = true
				end
			end, {
				desc = "Disable autoformat-on-save",
				bang = true,
			})
			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.disable_autoformat = false
				vim.g.disable_autoformat = false
			end, {
				desc = "Re-enable autoformat-on-save",
			})
		end,
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		opts = {
			-- Override the virtual text to show the number of lines folded
			fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
				local newVirtText = {}
				local suffix = (" 󰁂 %d "):format(endLnum - lnum)
				local sufWidth = vim.fn.strdisplaywidth(suffix)
				local targetWidth = width - sufWidth
				local curWidth = 0
				for _, chunk in ipairs(virtText) do
					local chunkText = chunk[1]
					local chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if targetWidth > curWidth + chunkWidth then
						table.insert(newVirtText, chunk)
					else
						chunkText = truncate(chunkText, targetWidth - curWidth)
						local hlGroup = chunk[2]
						table.insert(newVirtText, { chunkText, hlGroup })
						chunkWidth = vim.fn.strdisplaywidth(chunkText)
						-- str width returned from truncate() may less than 2nd argument, need padding
						if curWidth + chunkWidth < targetWidth then
							suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
						end
						break
					end
					curWidth = curWidth + chunkWidth
				end
				table.insert(newVirtText, { suffix, "MoreMsg" })
				return newVirtText
			end,
		},
		config = function(_, opts)
			-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
			-- Provider option 2: nvim lsp as LSP client
			-- Tell the server the capability of foldingRange,
			-- Neovim hasn't added foldingRange to default capabilities, users must add it manually			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}
			local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
			for _, ls in ipairs(language_servers) do
				require("lspconfig")[ls].setup({
					capabilities = capabilities,
					-- you can add other fields for setting up lsp server in this table
				})
			end
			require("ufo").setup(opts)
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
			{

				"JoosepAlviste/nvim-ts-context-commentstring",
				-- disable the default autocmd via the context_commentstring Integrations guide:
				-- https://github.com/JoosepAlviste/nvim-ts-context-commentstring/wiki/Integrations#nvim-comment
				opts = { enable_autocmd = false },
			},
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
					-- disable = function(lang, buf)
					-- 	local max_filesize = 20 * 1024 -- 20 KB
					-- 	local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					-- 	if ok and stats and stats.size > max_filesize then
					-- 		return true
					-- 	end
					-- end,
				},
				indent = { enable = true },

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

			-- Configure parser for Harmony lang
			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			parser_config.harmony = {
				install_info = {
					url = "~/cornell/cs4410-os/tree-sitter-harmony", -- local path or git repo
					files = { "src/parser.c" }, -- note that some parsers also require src/scanner.c or src/scanner.cc
					-- optional entries:
					branch = "main", -- default branch in case of git repo if different from master
					generate_requires_npm = false, -- if stand-alone parser without npm dependencies
					requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
				},
				filetype = "harmony", -- if filetype does not match the parser name
			}
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
			-- Debug Rust email-client project. See https://romangeber.com/blog/tech/nvim_rust_debugger to set up per-project debugger
			dap.adapters.lldb = { -- install with :Mason
				type = "executable",
				command = "/usr/bin/lldb-vscode",
				name = "lldb",
			}
			dap.configurations.rust = {
				{
					name = "email-client",
					type = "lldb",
					request = "launch",
					program = function()
						-- return vim.fn.getcwd() .. "/test_queue"
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = true,
					args = {},
				},
			}

			-- Debug C/C++
			-- dap.adapters.gdb = {
			-- 	type = "executable",
			-- 	command = "gdb",
			-- 	args = { "-i", "dap" },
			-- }

			-- Install cpptools with Mason
			-- https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(gdb-via--vscode-cpptools)
			dap.adapters.cppdbg = {
				type = "executable",
				command = "/home/adler/.local/share/nvim/mason/bin/OpenDebugAD7",
				id = "cppdbg",
			}
			dap.configurations.c = {
				{
					name = "Launch file",
					type = "cppdbg",
					request = "launch",
					program = function()
						-- return vim.fn.getcwd() .. "/test_queue"
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtEntry = true,
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
			"nvim-neotest/nvim-nio",
		},
		keys = {
			{ "<leader>dt", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = "Toggle Breakpoint" },
			{ "<leader>db", "<cmd>lua require'dap'.step_back()<cr>", desc = "Step Back" },
			{ "<leader>dc", "<cmd>lua require'dap'.continue()<cr>", desc = "Continue" },
			{ "<leader>dC", "<cmd>lua require'dap'.run_to_cursor()<cr>", desc = "Run To Cursor" },
			{ "<leader>dd", "<cmd>lua require'dap'.disconnect()<cr>", desc = "Disconnect" },
			{ "<leader>dg", "<cmd>lua require'dap'.session()<cr>", desc = "Get Session" },
			{ "<leader>di", "<cmd>lua require'dap'.step_into()<cr>", desc = "Step Into" },
			{ "<leader>do", "<cmd>lua require'dap'.step_over()<cr>", desc = "Step Over" },
			{ "<leader>du", "<cmd>lua require'dap'.step_out()<cr>", desc = "Step Out" },
			{ "<leader>dp", "<cmd>lua require'dap'.pause()<cr>", desc = "Pause" },
			{ "<leader>dr", "<cmd>lua require'dap'.repl.toggle()<cr>", desc = "Toggle Repl" },
			{ "<leader>ds", "<cmd>lua require'dap'.continue()<cr>", desc = "Start" },
			{ "<leader>dq", "<cmd>lua require'dap'.close()<cr>", desc = "Quit" },
			{ "<leader>dU", "<cmd>lua require'dapui'.toggle({reset = true})<cr>", desc = "Toggle UI" },
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
			dapui.setup()
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
		"altermo/ultimate-autopair.nvim",
		event = { "InsertEnter", "CmdlineEnter" },
		branch = "v0.6", --recommended as each new version will have breaking changes
		opts = {
			--Config goes here
		},
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
		version = "*",
		keys = {
			{ "<C-t>", desc = "Toggle Term" },
			{ "<C-S-t>", "<cmd>ToggleTermSendCurrentLine<cr>", desc = "Send current line to Terminal", mode = "n" },
			{ "<C-S-t>", "<cmd>ToggleTermSendVisualSelection<cr>", desc = "Send selection to Terminal", mode = "v" },
		},
		opts = { direction = "float", open_mapping = [[<C-t>]] },
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
				tmux = { enabled = false }, -- disables the tmux statusline
				kitty = { enabled = true, font = "-4" }, -- increase font size
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
				diagnostics_indicator = function(_, _, diagnostics, _)
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
		"brenoprata10/nvim-highlight-colors",
		opts = {
			enable_tailwind = true,
		},
	},
	{
		"NvChad/nvim-colorizer.lua",
		enable = false,
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
		enabled = true,
		main = "ibl",
		opts = {
			scope = {
				enabled = false,
			},
		},
	},
	{
		"JellyApple102/easyread.nvim",
		ft = { "text", "typst" },
		opts = {
			fileTypes = { "text", "typst", "markdown" },
		},
	},
	{
		"nmac427/guess-indent.nvim",
		lazy = false,
		config = true,
	},
	{
		"LunarVim/bigfile.nvim",
		lazy = false,
		opts = {},
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
	{
		"lervag/vimtex",
		init = function()
			-- Via README, "use init for config, do NOT use the more common 'config'"
			-- This [blog post](https://blog.epheme.re/software/nvim-latex.html) was very helpful in setting up Latex with nvim
			vim.g.vimtex_view_general_viewer = "zathura" -- make sure zathura is installed along with pdf plugin (e.g. zathura-pdf-mupdf)
			vim.g.vimtex_view_zathura_options = "-reuse-instance"
			vim.g.tex_flavor = "latex"
			vim.g.vimtex_compiler_method = "latexmk" -- make sure latexmk is installed
			vim.g.vimtex_compiler_latexmk = {
				callback = 1,
				continuous = 1,
				executable = "latexmk",
				options = {
					"-shell-escape",
					"-verbose",
					"-file-line-error",
					"-synctex=1",
					"-interaction=nonstopmode",
				},
			}
			-- vim.api.nvim_create_autocmd("BufReadPre", {
			-- 	pattern = "*.tex",
			-- 	callback = function()
			-- 		vim.api.nvim_buf_set_option(0, "vimtex_main", "~/cornell/math2210/project/main.tex")
			-- 	end,
			-- })
		end,
	},
	{

		"chomosuke/typst-preview.nvim",
		ft = "typst",
		version = "0.1.*",
		build = function()
			require("typst-preview").update()
		end,
	},
	{
		"ThePrimeagen/git-worktree.nvim",
		dependencies = "nvim-telescope/telescope.nvim",
		config = function()
			require("git-worktree").setup({
				-- change_directory_command = <str> -- default: "cd",
				-- update_on_change = <boolean> -- default: true,
				-- update_on_change_command = <str> -- default: "e .",
				-- clearjumps_on_change = <boolean> -- default: true,
				-- autopush = <boolean> -- default: false,
			})
			require("telescope").load_extension("git_worktree")
		end,
		keys = {
			{
				"<leader>gwta",
				":lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>",
				desc = "Git worktree add",
			},
		},
	},
	{
		"yorickpeterse/nvim-pqf",
		config = true,
	},
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		opts = {
			default_mappings = false,
			highlights = { -- They must have background color, otherwise the default color will be used
				incoming = "DiffAdd",
				current = "DiffText",
			},
			setup = function(_, opts)
				vim.api.nvim_set_hl(0, "DiffText", { fg = "#ffffff", bg = "#1d3b40" })
				vim.api.nvim_set_hl(0, "DiffAdd", { fg = "#ffffff", bg = "#1d3450" })
				require("git-conflict").setup(opts)
			end,
		},
		keys = {
			{ "<leader>gcr", "<CMD>GitConflictRefresh<CR>", desc = "Refresh" },
			{ "<leader>gcq", "<CMD>GitConflictListQf<CR>", desc = "All conflicts to quickfix" },
			{ "<leader>gcc", "<CMD>GitConflictChooseOurs<CR>", desc = "Select our [c]urrent changes" },
			{ "<leader>gci", "<CMD>GitConflictChooseTheirs<CR>", desc = "Select their [i]ncoming changes" },
			{ "<leader>gcb", "<CMD>GitConflictChooseBoth<CR>", desc = "Select [b]oth changes" },
			{ "<leader>gcn", "<CMD>GitConflictChooseNone<CR>", desc = "Select [n]one of the changes" },
		},
	},
	{
		"chentoast/marks.nvim",
		lazy = false,
		default_mappings = false,
		opts = {
			mapping = {
				set = "m", -- Sets a letter mark (will wait for input).;
				set_next = "m,",
				toggle = "m;", -- Set next available lowercase mark at cursor.
				delete_line = "dm-", -- Deletes all marks on current line.
				delete_buf = "dm<space>", -- Deletes all marks in current buffer.
				next = "m]", -- Goes to next mark in buffer.
				prev = "m[", -- Goes to previous mark in buffer.
				preview = "m:", -- Previews mark (will wait for user input). press <cr> to just preview the next mark.
				delete = "dm", -- Delete a letter mark (will wait for input).
				-- set_bookmark0 = "m0", -- Sets a bookmark from group[0-9].
				-- delete_bookmark[0-9] = "", -- Deletes all bookmarks from group[0-9].
				delete_bookmark = "dm=", -- Deletes the bookmark under the cursor.
				next_bookmark = "m}", -- Moves to the next bookmark having the same type as the bookmark under the cursor.
				prev_bookmark = "m{", -- Moves to the previous bookmark having the same type as the bookmark under the cursor.
				-- next_bookmark[0-9] = "", -- Moves to the next bookmark of the same group type. Works by first going according to line number, and then according to buffer number.
				-- prev_bookmark[0-9] = "", -- Moves to the previous bookmark of the same group type. Works by first going according to line number, and then according to buffer number.
				-- annotate = "", -- Prompts the user for a virtual line annotation that is then placed above the bookmark. Requires neovim 0.6+ and is not mapped by default.
			},
		},
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	{
		"dgagn/diagflow.nvim",
		event = "LspAttach",
		opts = {
			-- placement = "inline",
			-- inline_padding_left = 3,
		},
	},
	{
		"zbirenbaum/copilot.lua",
		event = "InsertEnter",
		cmd = "Copilot",
		opts = {
			panel = {
				enabled = false,
				keymap = {
					jump_prev = "[[",
					jump_next = "]]",
					accept = "<CR>",
					refresh = "gr",
					open = "<M-CR>",
				},
			},
			suggestion = {
				enabled = false, -- Using cmp source instead
				auto_trigger = false,
				keymap = {
					accept = "<M-l>",
					accept_word = false,
					accept_line = false,
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
		},
	},
})
