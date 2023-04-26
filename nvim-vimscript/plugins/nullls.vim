Plug 'jose-elias-alvarez/null-ls.nvim'

function! NullLSSetup()
lua << EOF
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.black.with({ extra_args = { "--fast", "--line-length", "79" } }),
        -- null_ls.builtins.formatting.autopep8.with({ extra_args = { "--experimental", "--aggressive" } }),
        -- null_ls.builtins.diagnostics.flake8,
        -- null_ls.builtins.completion.spell,
        null_ls.builtins.code_actions.gitsigns,
    },
    -- you can reuse a shared lspconfig on_attach callback here
    -- this is synchronous formatting. Guarantees no lost progress between formatting write/receive but also blocks
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                    vim.lsp.buf.formatting_sync()
                end,
            })
        end
    end,
})
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
require("null-ls").setup({
})
EOF
endfunction

augroup NullLSSetup
    autocmd!
    autocmd User PlugLoaded call NullLSSetup()
augroup end
