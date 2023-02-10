Plug 'nvim-telescope/telescope.nvim'

" Telescope Plugins
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fb <cmd>Telescope file_browser<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>ft <cmd>Telescope grep_string search=todo<cr>

function! TelescopeSetup()
lua << EOF
require('telescope').setup {
    defaults = {
      prompt_prefix = '🥴🔭> '
    }
}
require('telescope').load_extension('fzf')
EOF
endfunction

augroup TelescopeSetup
    autocmd!
    autocmd User PlugLoaded call TelescopeSetup()
augroup end
