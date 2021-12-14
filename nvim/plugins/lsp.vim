Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'

augroup LSPSetup
    autocmd!
    autocmd User PlugLoaded luafile ~/.config/nvim/plugins/lsp.lua
augroup end
