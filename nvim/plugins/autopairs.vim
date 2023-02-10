Plug 'windwp/nvim-autopairs'

function! AutopairsSetup()
lua << EOF
local npairs = require('nvim-autopairs')
local Rule = require("nvim-autopairs.rule")

require('nvim-autopairs').setup {
    disable_filetype = { "TelescopePrompt", "vim", "markdown" }, -- quote pairs are annoying when creating Vimscript comments
    disable_in_macro = true,
    -- Check treesitter for pairs
    check_ts = true,
    -- Disable pairs within certain treesitter nodes
    ts_config = {
        lua = { "string", "comment" },
        javascript = { "string", "template_string", "comment" },
        python = { "string", "comment", "source" },
        ocaml = { "string", "comment" },
    },
}

-- Custom pair rules:

-- Add OCaml comment pair
npairs.add_rule(Rule("(** ", " *", "ocaml"))

-- Add spaces between parentheses and jump space w/ closing parenthesis
npairs.add_rules {
  Rule(' ', ' ')
    :with_pair(function (opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({ '()', '[]', '{}' }, pair)
    end),
  Rule('( ', ' )')
      :with_pair(function() return false end)
      :with_move(function(opts)
          return opts.prev_char:match('.%)') ~= nil
      end)
      :use_key(')'),
  Rule('{ ', ' }')
      :with_pair(function() return false end)
      :with_move(function(opts)
          return opts.prev_char:match('.%}') ~= nil
      end)
      :use_key('}'),
  Rule('[ ', ' ]')
      :with_pair(function() return false end)
      :with_move(function(opts)
          return opts.prev_char:match('.%]') ~= nil
      end)
      :use_key(']')
}

-- Enable <CR> mapping
local cmp_autopairs = require "nvim-autopairs.completion.cmp"
local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
    return
end
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })

EOF
endfunction

augroup AutopairsSetup
    autocmd!
    autocmd User PlugLoaded call AutopairsSetup()
augroup end
