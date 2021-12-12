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
set signcolumn=auto:2
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

" Allow gf to open non-existent files TODO: open github 'links'
map gf :edit <cfile><cr>

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


" CS2024 increment next int after #
nnoremap cpp 5G^f#<C-A>


" ============================================================================
" 🔌 Plugins 🔌
" ============================================================================

" TODO: automatically install vim-plug
"
call plug#begin(stdpath('data') . '/plugged')

function! BuildComposer(info)
  if a:info.status != 'unchanged' || a:info.force
    if has('nvim')
      !cargo build --release --locked
    else
      !cargo build --release --locked --no-default-features --features json-rpc
    endif
  endif
endfunction

Plug 'euclio/vim-markdown-composer', { 'do': function('BuildComposer') }

" Color Scheme
Plug 'joshdick/onedark.vim'

" LSP 
Plug 'neovim/nvim-lspconfig'

" Lanugage Server Autocomplete
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'

" Snippets
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'

" DAP
Plug 'puremourning/vimspector', {
  \ 'do': 'python3 install_gadget.py --enable-vscode-cpptools'
  \ }

Plug 'mbbill/undotree'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'tmhedberg/SimpylFold'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'sheerun/vim-polyglot'
Plug 'editorconfig/editorconfig-vim' " TODO: see README for vim-fugitive compatibility
Plug 'christoomey/vim-tmux-navigator'
Plug 'JamshedVesuna/vim-markdown-preview'

" Vim markdown
Plug 'godlygeek/tabular'
" Plug 'plasticboy/vim-markdown' " Experiencing issues with this

" Telescope
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " Recommends updating the parsers on update
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

call plug#end()

" Colorscheme
colorscheme onedark

" TODO: move to plugin file
" Open the current file in the default program
nmap <leader>x :!xdg-open %<cr><cr>
let g:markdown_composer_open_browser=0
autocmd FileType markdown nmap <leader>x :ComposerOpen<cr>
