Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " Recommends updating the parsers on update
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'romgrk/nvim-treesitter-context'
Plug 'p00f/nvim-ts-rainbow'
Plug 'SmiteshP/nvim-gps'
Plug 'lewis6991/spellsitter.nvim'

" Folding
set foldmethod=expr
set foldexpr=nvim_treesitter#lsp#ui#vim#folding#foldexpr()
set foldtext=lsp#ui#vim#folding#foldtext()

function! TreeSitterSetup()
lua << EOF
    require'nvim-treesitter.configs'.setup {
        ensure_installed = 'maintained', -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
        ignore_install = {}, -- List of parsers to ignore installing
        highlight = {
            enable = true, -- false will disable the whole extension
            disable = {}, -- list of language that will be disabled
            additional_vim_regex_highlighting = false,
        },
        indent = {
            enable = true
        },
        context_commentstring = {
            enable = true
        },
        rainbow = {
            enable = true,
            extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
            max_file_lines = nil, -- Do not enable for files with more than n lines, int
            -- colors = {}, -- table of hex strings
            -- termcolors = {} -- table of colour name strings
        }
    }
    require'treesitter-context'.setup {
        enable = true,
        throttle = true, -- Throttles plugin updates (may improve performance)
        max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
        patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
            default = {
                'class',
                'function',
                'method',
            },
        },
    }
    require'nvim-gps'.setup()
    require'spellsitter'.setup()
EOF
endfunction

augroup TreeSitterSetup
    autocmd!
    autocmd User PlugLoaded call TreeSitterSetup()
augroup end
