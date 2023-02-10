Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " Recommends updating the parsers on update
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'romgrk/nvim-treesitter-context'
Plug 'p00f/nvim-ts-rainbow'
Plug 'SmiteshP/nvim-gps'
Plug 'lewis6991/spellsitter.nvim'

" Folding
set foldmethod=expr
set foldlevelstart=99
set foldexpr=nvim_treesitter#foldexpr()

function! TreeSitterSetup()
lua << EOF
    require'nvim-treesitter.configs'.setup {
        ensure_installed = { "c_sharp", "rst", "fennel", "teal", "ql", "c", "pascal", "bash", "comment", "html", "jsdoc", "rego", "hcl", "sparql", "glimmer", "clojure", "commonlisp", "cpp", "godot_resource", "javascript", "cuda", "turtle", "regex", "glsl", "dockerfile", "svelte", "dot", "rust", "ocamllex", "fusion", "css", "ledger", "bibtex", "elvish", "cooklang", "solidity", "python", "query", "cmake", "vala", "gomod", "zig", "gowork", "scheme", "graphql", "pioasm", "ruby", "typescript", "rasi", "perl", "make", "prisma", "scala", "fish", "json", "supercollider", "php", "http", "java", "llvm", "kotlin", "hocon", "hjson", "json5", "julia", "vim", "norg", "lua", "toml", "latex", "beancount", "erlang", "r", "devicetree", "elixir", "pug", "gdscript", "lalrpop", "gleam", "tsx", "surface", "jsonc", "scss", "eex", "heex", "yaml", "ocaml", "yang", "go", "astro", "ninja", "ocaml_interface", "wgsl", "nix", "tlaplus", "dart", "vue" },
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
        incremental_selection = {
            enable = true,
            keymaps = {
                -- I can't decide. All I know is that the defaults are terrible.
                -- init_selection = "gnn",
                -- node_incremental = "grn",
                -- scope_incremental = "grc",
                -- node_decremental = "grm",
                init_selection = "<leader>N",
                -- node_incremental = "<leader>nn",
                node_incremental = "<leader>]",
                scope_incremental = "<leader>grc",
                -- node_decremental = "<leader>np",
                node_decremental = "<leader>[",
            },
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
