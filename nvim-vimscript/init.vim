"
"                                     __
"                                    /__\
"                                   /(__)\
"                                  (__)(__)
"
"                             github.com/adlrwbr
"                       Made with ⌛&♥  by Adler Weber
"
" ============================================================================
" ⚙  General ⚙
" ============================================================================

set noswapfile
set nobackup
set undofile
set undodir=~/.config/nvim/undodir

" Spaces not tabs!
" TODO: how much of this is necessary?
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4

syntax on
set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey
set nowrap
set smartindent " Auto indent newlines
set hidden " Enable hidden buffers
set number " show current line number
set relativenumber " relative line nums
set incsearch " search and highlight before pressing enter
" set termguicolors
set signcolumn=yes:2
set ignorecase
set smartcase
set list
set listchars=tab:▸-◂,trail:·,precedes:◁,extends:▷
set scrolloff=8
set sidescrolloff=8
set nojoinspaces " insert only one space after '.?!' following join command
set splitright
set splitbelow
set foldopen=jump,mark,percent,search
set confirm
set autoread " auto read detected file changes - undo with u
set redrawtime=10000 " Allow more time for loading syntax on large files

" Reduce time for writing to swap file and firing CursorHold when the cursor
" isn't moving. This autocmd is used by various plugins for highlighting
set updatetime=750

" Enable spell checking for documents
autocmd FileType tex,text,markdown setlocal spell spelllang=en_us

" Configure opam
set rtp^="/home/adler/.opam/cs3110-2021fa/share/ocp-indent/vim"

" ============================================================================
" 🔑🗾 Key Maps 🔑🗾
" ============================================================================

" Remap leader
let mapleader = " "

" Open config file
nnoremap <leader>c :e ~/.config/nvim/init.vim<CR>

" Reload config file
nnoremap <leader>C :so ~/.config/nvim/init.vim<CR>

" No more escape
inoremap kj <esc>
inoremap KJ <esc>
vnoremap kj <esc>
inoremap <esc> <nop>

" Select all
nnoremap <leader>a ggVG

" Center and unfold search results
nnoremap n nzzzv
nnoremap N Nzzzv

" Past replace without copying
vnoremap <leader>p "_dP

" Reselect visual selection after indenting
vnoremap < <gv
vnoremap > >gv

" Allow gf to open non-existent files
noremap gf :edit <cfile><cr>

" Open shorthand github repositories in the browser, else do normal gx
" Greatly helps with plugin management
function! BetterGX()
    let l:link = expand('<cfile>')
    if l:link =~ '^[^/]\+/[^/]\+$'
        let l:link = 'https://github.com/' . l:link
    endif
    call netrw#BrowseX(l:link, netrw#CheckIfRemote())
endfunction
noremap <silent> gx :call BetterGX()<CR>

" Quickly insert trailing ; and ,
nnoremap <leader>; A;<esc>
nnoremap <leader>, A,<esc>

" Move visual block and reselect
vnoremap J :m '>+1<CR>gv
vnoremap K :m '<-2<CR>gv

" Switch windows
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k

" Temporarily stop search highlighting
noremap <leader>/ :noh<CR>

" Open the current file in the default program
nmap <leader>x :!xdg-open %<cr><cr>

" ============================================================================
" 🔌 Plugins 🔌
" ============================================================================

" Automatically install vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(data_dir . '/plugins')

" TODO: install a plugin to easily change my working dir

Plug 'nvim-lua/plenary.nvim'
Plug 'ap/vim-css-color'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'mbbill/undotree'
Plug 'scrooloose/nerdtree'
" Plug 'scrooloose/syntastic'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'

source ~/.config/nvim/plugins/nvim-lint.vim
source ~/.config/nvim/plugins/autopairs.vim
" source ~/.config/nvim/plugins/dap.vim
source ~/.config/nvim/plugins/dracula.vim
source ~/.config/nvim/plugins/editorconfig.vim
source ~/.config/nvim/plugins/gitsigns.vim
source ~/.config/nvim/plugins/lsp.vim
source ~/.config/nvim/plugins/lualine.vim
source ~/.config/nvim/plugins/markdown-composer.vim
" source ~/.config/nvim/plugins/nullls.vim
source ~/.config/nvim/plugins/quickscope.vim
source ~/.config/nvim/plugins/telescope.vim
source ~/.config/nvim/plugins/tmux.nvim.vim
source ~/.config/nvim/plugins/treesitter.vim
source ~/.config/nvim/plugins/vimspector.vim

call plug#end()

" A trick by Jess Archer to execute commands within discrete plugin files
" after all plugins have loaded
doautocmd User PlugLoaded
