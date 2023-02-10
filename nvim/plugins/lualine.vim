Plug 'nvim-lualine/lualine.nvim'

function! LualineSetup()
lua << EOF
  local gps = require('nvim-gps')
  require'lualine'.setup {
    options = {
      icons_enabled = true,
      theme = 'dracula',
      section_separators = { left = '', right = ''},
      component_separators = { left = '', right = ''},
      disabled_filetypes = {},
      always_divide_middle = true,
      },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff'},
      lualine_c = {'filename', { gps.get_location, cond = gps.is_available }},
      lualine_x = {'fileformat', 'encoding', 'filetype'},
      lualine_y = {'diagnostics'},
      lualine_z = {'progress', 'location'}
      },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {'filename'},
      lualine_c = {{ gps.get_location, cond = gps.is_available }},
      lualine_x = {'location'},
      lualine_y = {},
      lualine_z = {}
      },
    tabline = {},
    extensions = {}
    }
EOF
endfunction

augroup LualineSetup
    autocmd!
    autocmd User PlugLoaded call LualineSetup()
augroup end
