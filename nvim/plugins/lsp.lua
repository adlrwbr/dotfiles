-- Key Mappings
-- See `:help vim.lsp.*` for documentation on any of the below functions
local function nkeymap(key, map)
    vim.api.nvim_set_keymap('n', key, map, { noremap = true })
end
nkeymap('gD', ':lua vim.lsp.buf.declaration()<CR>')
nkeymap('gd', ':lua vim.lsp.buf.definition()<CR>')
nkeymap('gi', ':lua vim.lsp.buf.implementation()<CR>')
nkeymap('gr', ':lua vim.lsp.buf.references()<CR>')
nkeymap('gT', ':lua vim.lsp.buf.type_definition()<CR>')
nkeymap('K', ':lua vim.lsp.buf.hover()<CR>')
nkeymap('<C-k>', ':lua vim.lsp.buf.signature_help()<CR>')
nkeymap('<leader>wa', ':lua vim.lsp.buf.add_workspace_folder()<CR>')
nkeymap('<leader>wr', ':lua vim.lsp.buf.remove_workspace_folder()<CR>')
nkeymap('<leader>wl', ':lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
nkeymap('<leader>rn', ':lua vim.lsp.buf.rename()<CR>')
nkeymap('<leader>ca', ':lua vim.lsp.buf.code_action()<CR>')
nkeymap('<leader>e', ':lua vim.diagnostic.open_float()<CR>')
nkeymap('[d', ':lua vim.diagnostic.goto_prev()<CR>')
nkeymap(']d', ':lua vim.diagnostic.goto_next()<CR>')
nkeymap('<leader>q', ':lua vim.diagnostic.setloclist()<CR>')
nkeymap('<leader>f', ':lua vim.lsp.buf.formatting()<CR>')

-- Setup completion and snippet engine.
local cmp = require'cmp'
local luasnip = require'luasnip'
cmp.setup({
    mapping = {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<BS>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.close()
            else
                fallback()
            end
        end, { "i", "s" }),
        -- Like JetBrains: Enter to insert, Tab to replace
        -- TODO: Insert not working. See https://github.com/hrsh7th/nvim-cmp/issues/664
        -- Accept currently selected item. If none selected, `select` first item.
        -- Set `select` to `false` to only confirm explicitly selected items.
        ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    },
    -- Priority of sources:
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'path' },
        { name = 'luasnip' },
        { name = 'emoji' },
        { name = 'buffer', keyword_length = 4 },
    }),
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    formatting = {
        format = require("lspkind").cmp_format({
            with_text = true,
            menu = ({
                -- latex_symbols = '[Latex]', -- TODO install
                buffer = '[Buf]',
                emoji = '[Emoji]',
                luasnip = '[LuaSnip]',
                nvim_lsp = '[LSP]',
                nvim_lua = '[API]',
                path = '[Path]',
            })
        }),
    },
    experimental = {
        ghost_text = true,
        native_menu = false
    }
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    sources = cmp.config.sources({
        { name = 'buffer' },
        { name = 'emoji' }
    })
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
        { name = 'path' },
        { name = 'cmdline' }
    })
})

-- Load friendly snippets
require("luasnip.loaders.from_vscode").lazy_load({
    paths = "~/.local/share/nvim/plugged/friendly-snippets",
    include = nil, -- Load all languages
    exclude = {}
})

-- Advertise nvim-cmp support to LSPs (LSP can use snippets and whatnot)
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Setup LSP installer
local lsp_installer = require("nvim-lsp-installer")
lsp_installer.settings({
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
})
-- Setup LSP servers
lsp_installer.on_server_ready(function(server)
    local opts = {
        capabilities = capabilities,
    }
    -- Make Lua language server aware of built-in vim globals
    if server.name == "sumneko_lua" then
        opts = {
            capabilities = capabilities,
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { 'vim', 'use' }
                    }
                }
            }
        }
    end
    -- This setup() function is exactly the same as lspconfig's setup function.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    server:setup(opts)
end)
