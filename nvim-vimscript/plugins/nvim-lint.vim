Plug 'mfussenegger/nvim-lint'

function! LintSetup()
lua << EOF
require('lint').linters_by_ft = {
  -- :setfiletype <autocomplete> to view known filetypes
  javascript = {'eslint'},
  markdown = {'vale'},
  python = {'mypy', 'pydocstyle', 'pycodestyle'},
}
EOF
endfunction

augroup LintSetup
    autocmd!
    autocmd User PlugLoaded call LintSetup()
    autocmd BufWrite,InsertLeave <buffer> lua require('lint').try_lint()
    " Too slow:
    " autocmd BufRead,BufNewFile,InsertLeave <buffer> lua require('lint').try_lint()
augroup end

