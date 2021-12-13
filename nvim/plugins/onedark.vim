Plug 'joshdick/onedark.vim'

augroup OneDarkSetup
    autocmd!
    autocmd User PlugLoaded ++nested colorscheme onedark
augroup end
