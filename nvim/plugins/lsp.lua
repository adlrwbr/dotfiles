-- Key Mappings
-- See `:help vim.lsp.*` for documentation on any of the below functions
local function nkeymap(key, map)
	vim.api.nvim_set_keymap("n", key, map, { noremap = true })
end

nkeymap("gD", ":lua vim.lsp.buf.declaration()<CR>")
nkeymap("gd", ":lua vim.lsp.buf.definition()<CR>")
nkeymap("gi", ":lua vim.lsp.buf.implementation()<CR>")
nkeymap("gr", ":lua vim.lsp.buf.references()<CR>")
nkeymap("gT", ":lua vim.lsp.buf.type_definition()<CR>")
nkeymap("K", ":lua vim.lsp.buf.hover()<CR>")
nkeymap("<C-k>", ":lua vim.lsp.buf.signature_help()<CR>")
nkeymap("<leader>wa", ":lua vim.lsp.buf.add_workspace_folder()<CR>")
nkeymap("<leader>wr", ":lua vim.lsp.buf.remove_workspace_folder()<CR>")
nkeymap("<leader>wl", ":lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>")
nkeymap("<leader>rn", ":lua vim.lsp.buf.rename()<CR>")
nkeymap("<leader>ca", ":lua vim.lsp.buf.code_action()<CR>")
nkeymap("<leader>e", ":lua vim.diagnostic.open_float()<CR>")
nkeymap("[d", ":lua vim.diagnostic.goto_prev()<CR>")
nkeymap("]d", ":lua vim.diagnostic.goto_next()<CR>")
nkeymap("<leader>q", ":lua vim.diagnostic.setloclist()<CR>")
nkeymap("<leader>f", ":lua vim.lsp.buf.formatting()<CR>")

-- Setup completion and snippet engine
-- TODO: don't suggest snippet source when in comment
-- TODO: don't suggest the same word
-- TODO: don't suggest text from buffer if current word is valid
-- TODO: fuzzy find LSP suggestions. Like `BTreeMap` will suggest `collections::BTreeMap`. Might be an LSP issue.
local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
	mapping = {
		["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
		["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
		["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
		["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
		["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
		["<C-e>"] = cmp.mapping.abort(),
		-- Kind of like JetBrains: Alt-Enter to insert, Tab to replace
		-- Set `select` to `false` to only confirm explicitly selected items.
		["<A-CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
			elseif luasnip.expand_or_locally_jumpable() then
				-- TODO: print node number / number of nodes
				if luasnip.choice_active() then
					print(luasnip.get_current_choices())
				end
				-- luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if luasnip.jumpable(-1) then
				print("jumped backward")
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	-- Priority of sources:
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "path" },
		{ name = "luasnip" },
		{ name = "emoji" },
		{ name = "buffer", keyword_length = 4 },
	}),
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	formatting = {
		format = require("lspkind").cmp_format({
			with_text = true,
			menu = {
				-- latex_symbols = '[Latex]', -- TODO install
				buffer = "[Buf]",
				emoji = "[Emoji]",
				luasnip = "[LuaSnip]",
				nvim_lsp = "[LSP]",
				nvim_lua = "[API]",
				path = "[Path]",
			},
		}),
	},
	experimental = {
		ghost_text = true,
		native_menu = false,
	},
	window = {
		-- :h nvim_open_win
		completion = {
			-- winhighlight = "Normal:None,FloatBorder:None,Search:None",
			-- winhighlight = "Normal:None",
            -- CursorLine: "selected item"
			winhighlight = "Normal:None,FloatBorder:None,CursorLine:Pmenu,Search:None",
			border = "rounded",
			-- col_offset = -3,
			-- side_padding = 0,
		},
		documentation = {
			-- winhighlight = "Normal:None,FloatBorder:None,Search:None",
            -- winhighlight = "FloatBorder:Pmenu",
			-- border = { "╔", "═" ,"╗", " ║", "╝", "═", "╚", "║"  },
			border = "rounded",
			max_width = 80,
			min_width = 50,
			side_padding = 10
			-- max_height = math.floor(vim.o.lines * 0.4),
			-- min_height = 3,
		}
	},
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "buffer" },
		{ name = "emoji" },
	}),
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
		{ name = "cmdline" },
	}),
})

-- Setup luasnip
local types = require("luasnip.util.types")
-- TODO: search for snippets in cmp based off of their expanded text
-- ex typing "if __" should suggest the "if __name__ == '__main__':" snippet
require("luasnip").config.setup({
	history = false,
	enable_autosnippets = true,
	ext_opts = {
		[types.choiceNode] = {
			active = {
				--virt_text = { { "choiceNode" } }
			},
		},
		[types.insertNode] = {
			active = {
				--virt_text = { { "insertNode" } }
			},
		},
	},
})

-- Load friendly snippets
require("luasnip.loaders.from_vscode").lazy_load({
	paths = "~/.local/share/nvim/plugged/friendly-snippets",
	include = nil, -- Load all languages
	exclude = {},
})

-- Advertise nvim-cmp support to LSPs (LSP can use snippets and whatnot)
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Setup LSP installer
local lsp_installer = require("nvim-lsp-installer")
lsp_installer.settings({
	ui = {
		icons = {
			server_installed = "✓",
			server_pending = "➜",
			server_uninstalled = "✗",
		},
	},
})
-- Setup LSP servers
lsp_installer.on_server_ready(function(server)
	local opts = {
		capabilities = capabilities,
	}
	-- Make Lua language server aware of built-in vim globals
	if server.name == "sumneko_lua" then
		-- These options are passed as the lspconfig options
		opts = {
			capabilities = capabilities,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim", "use" },
					},
				},
			},
		}
	end
	-- Temporarily fix outdated OCaml NPM language server until issue resolved
	if server.name == "ocamlls" then
		opts = {
			capabilities = capabilities,
			-- Configure dune build keybind
			on_attach = function(_, bufnr)
				vim.api.nvim_buf_set_keymap(
					bufnr,
					"n",
					"<leader>mb",
					"<cmd>!make build<CR>",
					{ noremap = true, silent = false }
				)
				vim.api.nvim_buf_set_keymap(
					bufnr,
					"n",
					"<leader>mt",
					"<cmd>!make test<CR>",
					{ noremap = true, silent = false }
				)
				vim.api.nvim_buf_set_keymap(
					bufnr,
					"n",
					"<leader>mc",
					"<cmd>!make check<CR>",
					{ noremap = true, silent = false }
				)
				vim.api.nvim_buf_set_keymap(
					bufnr,
					"n",
					"<leader>mz",
					"<cmd>!make zip<CR>",
					{ noremap = true, silent = false }
				)
				vim.api.nvim_buf_set_keymap(
					bufnr,
					"n",
					"<leader>mp",
					"<cmd>!make play<CR>",
					{ noremap = true, silent = false }
				)
			end,
			cmd = { "ocamllsp" },
			root_dir = require("lspconfig.util").root_pattern("*.opam", "esy.json", "package.json", ".git", "dune"),
		}
	end
	server:setup(opts)
end)
