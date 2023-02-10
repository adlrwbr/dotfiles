Plug 'aserowy/tmux.nvim'

function! TMUXSetup()
lua << EOF
  require("tmux").setup({
    copy_sync = {
      enable = true,
    },
    navigation = {
      enable_default_keybindings = true,
    },
    resize = {
      enable_default_keybindings = true,
    }
  })
EOF
endfunction

augroup TMUXSetup
  autocmd!
  autocmd User PlugLoaded call TMUXSetup()
augroup end
