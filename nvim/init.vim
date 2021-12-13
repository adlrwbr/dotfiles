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
set confirm
set autoread " auto read detected file changes - undo with u
set redrawtime=10000 " Allow more time for loading syntax on large files

" Reduce time for writing to swap file and firing CursorHold when the cursor
" isn't moving. This autocmd is used by various plugins for highlighting
set updatetime=750

" Enable spell checking for documents
autocmd FileType tex,text,markdown setlocal spell spelllang=en_us

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
vnoremap KJ <esc>
inoremap <esc> <nop>

" Center and unfold search results
nnoremap n nzzzv
nnoremap N Nzzzv

" TODO Unfold go to line
" nnoremap num gg ggzv
" nnoremap num G ggzv

" Past replace without copying
vnoremap <leader>p "_dP

" Reselect visual selection after indenting
vnoremap < <gv
vnoremap > >gv

" Allow gf to open non-existent files
noremap gf :edit <cfile><cr>

" TODO: map gx to open github links, which will help with plugin management

" Quickly insert trailing ;
nnoremap <leader>; A;<esc>

" Move visual block
vnoremap J :m '>+1<CR>
vnoremap K :m '<-2<CR>

" Create curly braces
inoremap {<CR> {<CR>}<esc>O

" Switch windows
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k

" Temporarily stop search highlighting
noremap <leader>/ :noh<CR>

" Make Y behave like other capitals
nnoremap Y y$

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

source ~/.config/nvim/plugins/airline.vim
source ~/.config/nvim/plugins/vimspector.vim
source ~/.config/nvim/plugins/editorconfig.vim
source ~/.config/nvim/plugins/lsp.vim
source ~/.config/nvim/plugins/markdown-composer.vim
source ~/.config/nvim/plugins/onedark.vim
source ~/.config/nvim/plugins/quickscope.vim
source ~/.config/nvim/plugins/telescope.vim

Plug 'ap/vim-css-color'
Plug 'mbbill/undotree'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'tmhedberg/SimpylFold'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'sheerun/vim-polyglot'
Plug 'christoomey/vim-tmux-navigator'
Plug 'JamshedVesuna/vim-markdown-preview'

call plug#end()

" A trick by Jess Archer to execute commands within discrete plugin files
" after all plugins have loaded
doautocmd User PlugLoaded
