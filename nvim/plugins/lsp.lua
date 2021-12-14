-- LSP Installer
local lsp_installer = require("nvim-lsp-installer")
lsp_installer.on_server_ready(function(server)
    local opts = {}
    -- Make Lua language server aware of built-in vim globals
    if server.name == "sumneko_lua" then
        opts = {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { 'vim', 'use' }
                    }
                }
            }
        }
    end
    server:setup(opts)
end)
-- Key Mappings
-- See `:help vim.lsp.*` for documentation on any of the below functions
local function nkeymap(key, map)
    vim.api.nvim_set_keymap('n', key, map, { noremap = true })
end
nkeymap('gD', ':lua vim.lsp.buf.declaration()<CR>')
nkeymap('gd', ':lua vim.lsp.buf.definition()<CR>')
nkeymap('gi', ':lua vim.lsp.buf.implementation()<CR>')
nkeymap('gr', ':lua vim.lsp.buf.references()<CR>')
nkeymap('K', ':lua vim.lsp.buf.hover()<CR>')
nkeymap('<C-k>', ':lua vim.lsp.buf.signature_help()<CR>')
nkeymap('<leader>wa', ':lua vim.lsp.buf.add_workspace_folder()<CR>')
nkeymap('<leader>wr', ':lua vim.lsp.buf.remove_workspace_folder()<CR>')
nkeymap('<leader>wl', ':lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
nkeymap('<leader>D', ':lua vim.lsp.buf.type_definition()<CR>')
nkeymap('<leader>rn', ':lua vim.lsp.buf.rename()<CR>')
nkeymap('<leader>ca', ':lua vim.lsp.buf.code_action()<CR>')
nkeymap('<leader>e', ':lua vim.diagnostic.open_float()<CR>')
nkeymap('[d', ':lua vim.diagnostic.goto_prev()<CR>')
nkeymap(']d', ':lua vim.diagnostic.goto_next()<CR>')
nkeymap('<leader>q', ':lua vim.diagnostic.setloclist()<CR>')
nkeymap('<leader>f', ':lua vim.lsp.buf.formatting()<CR>')
