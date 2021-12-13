Plug 'joshdick/onedark.vim'

augroup OneDarkOverrides
    autocmd!
    autocmd User PlugLoaded ++nested colorscheme onedark
augroup end
