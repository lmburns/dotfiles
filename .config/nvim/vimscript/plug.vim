"============================================================================
"    Author: Lucas Burns                                                   
"     Email: burnsac@me.com                                                
"      Home: https://github.com/lmburns                                    
"============================================================================

call plug#begin("~/.vim/plugged")

Plug 'junegunn/vim-plug'

" ============== lightline-buffer ============== {{{
"   let s:nbsp = ' '
"   let g:lightline#bufferline#filename_modifier = ":t".s:nbsp
"   let g:lightline#bufferline#shorten_path      = 1
"   let g:lightline#bufferline#show_number       = 2
"   let g:lightline#bufferline#min_buffer_count  = 0
"   let g:lightline#bufferline#unnamed           = '[No Name]'
"   let g:lightline#bufferline#read_only         = '  '
"   let g:lightline#bufferline#modified          = " + "
"   let g:lightline#bufferline#enable_devicons = 1
"   let g:lightline#bufferline#unicode_symbols = 1
"   let g:lightline#bufferline#number_map = {
"   \ 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴',
"   \ 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹'}
"   " \ 0: '₀', 1: '₁', 2: '₂', 3: '₃', 4: '₄',
"   " \ 5: '₅', 6: '₆', 7: '₇', 8: '₈', 9: '₉'}
"   let g:lightline#bufferline#unicode_symbols = 1
"
"   let g:lightline#gitdiff#indicator_added = ': '
"   let g:lightline#gitdiff#indicator_deleted = ': '
"   let g:lightline#gitdiff#indicator_modified = 'ﰲ: '
"   let g:lightline#gitdiff#separator = ' '
" let g:lightline#gitdiff#show_empty_indicators = 1
" }}} === lightline-buffer ===

" ============== lightline ============== {{{
" Plug 'itchyny/lightline.vim'
" Plug 'josa42/vim-lightline-coc'
" Plug 'niklaas/lightline-gitdiff'
" function! CocDiagnosticError() abort "{{{
"   let info = get(b:, 'coc_diagnostic_info', {})
"   return get(info, 'error', 0) ==# 0 ? '' : ' ' . info['error'] "   
" endfunction "}}}
"
" function! CocDiagnosticWarning() abort "{{{
"   let info = get(b:, 'coc_diagnostic_info', {})
"   return get(info, 'warning', 0) ==# 0 ? '' : ' ' . info['warning'] "      !
" endfunction "}}}
"
" function! CocDiagnosticOK() abort "{{{
"   let info = get(b:, 'coc_diagnostic_info', {})
"   return get(info, 'error', 0) ==# 0 && get(info, 'warning', 0) ==# 0 ? '' : '' "  
" endfunction "}}}
"
" function! CocStatus() abort "{{{
"   return get(g:, 'coc_status', '')
" endfunction "}}}

" function! FileSize() abort "{{{
"   let [ bytes, units, i ] = [ getfsize(expand(@%)), ['', 'Ki', 'Mi', 'Gi'], 0 ]
"   while bytes >= 1024 | let bytes = bytes / 1024.0 | let i += 1 | endwhile
"   return printf((i ? "~%.1f" : "%d")." %sB", bytes, units[i])
" endfunction "}}}

function! GitGlobal() abort "{{{
  if exists('*FugitiveHead')
    let branch = FugitiveHead()
    if branch ==# ''
      return ' ' . fnamemodify(getcwd(), ':t')
    else
      return branch . ' '
    endif
  endif
  return ''
endfunction "}}}

let g:ll_blacklist = '\v(help|nerdtree|quickmenu|startify|undotree|neoterm|'
      \ . 'fugitive|netrw|vim-plug|floaterm|qf)'

function! FileSize() abort " {{{
  let l:bytes = getfsize(expand('%:p'))
  if (l:bytes >= 1024)
    let l:kbytes = l:bytes / 1024
  endif
  if (exists('l:kbytes') && l:kbytes >= 1000)
    let l:mbytes = l:kbytes / 1000
  endif

  if l:bytes <= 0
    return &filetype !~# g:ll_blacklist ? ('0 B') : ''
  endif

  if (exists('l:mbytes'))
    return &filetype !~# g:ll_blacklist && winwidth(0) > 70 ? (l:mbytes . ' MB') : ''
  elseif (exists('l:kbytes'))
    return &filetype !~# g:ll_blacklist && winwidth(0) > 70 ? (l:kbytes . ' KB') : ''
  else
    return &filetype !~# g:ll_blacklist && winwidth(0) > 70 ? (l:bytes . ' B') : ''
  endif
endfunction "}}}

let g:lightline = {}
let g:lightline.colorscheme = 'kimbox'
let g:lightline.separator = { 'left': "\ue0b8", 'right': "\ue0be" }
let g:lightline.subseparator = { 'left': "\ue0b9", 'right': "\ue0b9" }
let g:lightline.tabline_separator = { 'left': "\ue0bc", 'right': "\ue0ba" }
let g:lightline.tabline_subseparator = { 'left': "\ue0bb", 'right': "\ue0bb" }
" 'fileformat'
let g:lightline.active = {
      \ 'left':  [['mode', 'paste'],
      \           ['readonly', 'modified', 'devicons_filetype', 'fsize', 'fileencoding'],
      \           ['gitdiff', 'coc_status']],
      \ 'right': [['lineinfo'],
      \           ['linter_errors', 'linter_warnings', 'linter_ok']]
      \ }
let g:lightline.inactive = {
      \ 'left': [['filename', 'modified', 'fileformat']],
      \ 'right': [[ 'lineinfo' ]]
      \ }
" 'tabs'
let g:lightline.tabline = {
      \ 'right': [[ 'method', 'git_status' ]],
      \ 'left': [['vim_logo', 'nbufs', 'buffers']],
      \ }
let g:lightline.tab = {
      \ 'active': ['bufnum', 'filename'],
      \ 'inactive': ['bufnum', 'filename']
      \ }
let g:lightline.tab_component_function = {
      \ 'tabnum': 'TabNum',
      \ 'filename': 'LightlineFilename',
      \ }
let g:lightline.component = {
      \ 'git_status' : '%{GitGlobal()}',
      \ 'nbufs': '%{NumBufs()}',
      \ 'bufinfo': '%{bufname("%")}:%{bufnr("%")}',
      \ 'vim_logo': "\ue7c5",
      \ 'mode': '%{lightline#mode()}',
      \ 'absolutepath': '%F',
      \ 'relativepath': '%f',
      \ 'filename': '%t',
      \ 'fileformat': '%{&fenc!=#""?&fenc:&enc}[%{&ff}]',
      \ 'filetype': '%{&ft!=#""?&ft:"no ft"}',
      \ 'modified': '%M',
      \ 'bufnum': '%n',
      \ 'paste': '%{&paste?"PASTE":""}',
      \ 'readonly': '%R',
      \ 'charvalue': '%b',
      \ 'charvaluehex': '%B',
      \ 'percent': '%2p%%',
      \ 'percentwin': '%P',
      \ 'spell': '%{&spell?&spelllang:""}',
      \ 'lineinfo': '%2p%% %3l:%-2v',
      \ 'line': '%l',
      \ 'column': '%c',
      \ 'close': '%999X X ',
      \ 'winnr': '%{winnr()}',
      \ 'method': '%{NearestMethodOrFunction()}',
      \ }
let g:lightline.component_function = {
      \ 'devicons_filetype': 'DeviconsFiletype',
      \ 'coc_status': 'CocStatus',
      \ 'fsize': 'FileSize',
      \ 'fileencoding': 'LightlineFileEncoding',
      \ }
let g:lightline.component_expand = {
      \ 'linter_warnings': 'CocDiagnosticWarning',
      \ 'linter_errors': 'CocDiagnosticError',
      \ 'linter_ok': 'CocDiagnosticOK',
      \ 'buffers': 'lightline#bufferline#buffers',
      \ 'readonly': 'LightLineReadonly',
      \ 'gitdiff': 'lightline#gitdiff#get',
      \ }
let g:lightline.component_type = {
      \ 'linter_warnings': 'warning',
      \ 'linter_errors': 'error',
      \ 'linter_info': 'info',
      \ 'linter_hints': 'hints',
      \ 'buffers': 'tabsel',
      \ 'gitdiff': 'middle',
      \ }
let g:lightline.mode_map = {
      \ 'n':      'N',
      \ 'i':      'I',
      \ 'R':      'R',
      \ 'v':      'V',
      \ 'V':      'V-L',
      \ "\<C-v>": 'V-B',
      \ 'c':      'C',
      \ 's':      'S',
      \ 'S':      'S-L',
      \ "\<C-s>": 'S-B',
      \ 't':      'T',
      \ }
" }}} === lightline ===

" ============== Themes ============== {{{
" Plug 'AlessandroYorba/Alduin'
" Plug 'franbach/miramare'
" Plug 'wojciechkepka/bogster'
" Plug 'wojciechkepka/vim-github-dark'
" Plug 'haishanh/night-owl.vim'
" Plug 'ackyshake/Spacegray.vim'
" Plug 'bluz71/vim-nightfly-guicolors'
" Plug 'savq/melange'
" Plug 'ajmwagar/vim-deus'
" Plug 'habamax/vim-gruvbit'
Plug 'lmburns/kimbox'
" Plug 'lmburns/overcast'
" Plug 'nanotech/jellybeans.vim'
" Plug 'cocopon/iceberg.vim'
" Plug 'sainnhe/gruvbox-material'
" Plug 'sainnhe/edge'
" Plug 'sainnhe/everforest'
" Plug 'b4skyx/serenade'
" Plug 'joshdick/onedark.vim'
" Plug 'pineapplegiant/spaceduck', { 'branch': 'main' }
" Plug 'ghifarit53/daycula-vim' , {'branch' : 'main'}
" Plug 'ghifarit53/tokyonight-vim'
" Plug 'srcery-colors/srcery-vim'
" Plug 'wadackel/vim-dogrun'
" Plug 'glepnir/oceanic-material'
" Plug 'drewtempelmeyer/palenight.vim'
" Plug 'KeitaNakamura/neodark.vim'
" Plug 'tyrannicaltoucan/vim-deep-space'

" Lua
" Plug 'marko-cerovac/material.nvim'
" Plug 'sainnhe/sonokai'
" }}} === Themes ===

call plug#end()

" ============== Theme Settings ============== {{{
" let g:gruvbox_material_background = 'medium'
" let g:gruvbox_material_palette = 'mix'
" " let g:gruvbox_material_palette = 'material'
" let g:gruvbox_material_background = 'hard'
" let g:gruvbox_material_enable_bold = 1
" let g:gruvbox_material_disable_italic_comment = 1
" let g:gruvbox_material_current_word = 'grey background'
" let g:gruvbox_material_visual = 'grey background'
" let g:gruvbox_material_cursor = 'green'
" let g:gruvbox_material_sign_column_background = 'none'
" let g:gruvbox_material_statusline_style = 'mix'
" let g:gruvbox_material_better_performance = 1
" let g:gruvbox_material_diagnostic_text_highlight = 0
" let g:gruvbox_material_diagnostic_line_highlight = 0
" let g:gruvbox_material_diagnostic_virtual_text = 'colored'

" let g:kimbox_background = 'deep'
" let g:kimbox_background = 'medium' " brown
" let g:kimbox_background = 'darker' " dark dark purple
" let g:kimbox_background = 'ocean' " dark purple
" let g:kimbox_allow_bold = 1
" let g:overcast_allow_bold = 1
"
" let g:oceanic_material_background = "ocean"
" " let g:oceanic_material_background = "deep"
" " let g:oceanic_material_background = "medium"
" " let g:oceanic_material_background = "darker"
" let g:oceanic_material_allow_bold = 1
" let g:oceanic_material_allow_italic = 1
" let g:oceanic_material_allow_underline = 1
"
" let g:everforest_disable_italic_comment = 1
" let g:everforest_background = 'hard'
" let g:everforest_enable_italic = 0
" let g:everforest_sign_column_background = 'none'
" let g:everforest_better_performance = 1
"
" let g:edge_style = 'aura'
" let g:edge_cursor = 'blue'
" let g:edge_sign_column_background = 'none'
" let g:edge_better_performance = 1
"
" " let g:material_theme_style = 'darker-community'
" let g:material_theme_style = 'ocean-community'
" let g:material_terminal_italics = 1
"
" " maia atlantis era
" " let g:sonokai_style = 'andromeda'
" let g:sonokai_style = 'shusia'
" let g:sonokai_enable_italic = 1
" let g:sonokai_disable_italic_comment = 1
" let g:sonokai_cursor = 'blue'
" let g:sonokai_sign_column_background = 'none'
" let g:sonokai_better_performance = 1
" let g:sonokai_diagnostic_text_highlight = 0
"
" " let g:miramare_enable_italic = 1
" let g:miramare_enable_bold = 1
" let g:miramare_disable_italic_comment = 1
" let g:miramare_cursor = 'purple'
" let g:miramare_current_word = 'grey background'
"
" let g:gruvbox_contrast_dark = 'medium'
" let g:spacegray_use_italics = 1
"
" func! s:gruvbit_setup() abort
"   hi Comment gui=italic cterm=italic
"   hi Statement gui=bold cterm=bold
"   hi Comment gui=italic cterm=italic
" endfunc
"
" augroup colorscheme_change | au!
"   au ColorScheme gruvbit call s:gruvbit_setup()
" augroup END

set guioptions-=m
set guioptions-=r
set guioptions-=L

" let g:neovide_cursor_animation_length = 0.15
" let g:neovide_remember_window_size = v:true
" let g:neovide_input_use_logo = v:true
" let g:neovide_transparency=0.9
" let g:neovide_cursor_vfx_particle_lifetime=2.0
" let g:neovide_cursor_vfx_particle_density=12.0
" let g:neovide_cursor_vfx_mode = 'torpedo'
" let g:neovide_cursor_vfx_mode = "pixiedust"

" syntax enable
" colorscheme kimbox
" colorscheme overcast
" colorscheme serenade
" colorscheme everforest
" colorscheme gruvbox-material
" colorscheme sonokai
" colorscheme oceanic_material
" colorscheme spaceduck
" colorscheme bogster
" colorscheme material
" colorscheme miramare
" colorscheme night-owl
" colorscheme jellybeans
" colorscheme gruvbit
" colorscheme deep-space
" colorscheme melange
" colorscheme iceberg
" coloscheme OceanicNext
" colorscheme deus
" colorscheme onedark
" colorscheme neodark
" colorscheme spaceway    " needs work
" colorscheme alduin      " needs work
" colorscheme spacegray
" colorscheme tokyonight

" colorscheme material
" edge daycula srcery dogrun palenight

" }}} === Theme Settings ===

" lua require('plugs/treesitter')

" augroup jump_last_position
"   autocmd!
"   autocmd BufRead * if line("'\"") > 0 && line("'\"") <= line("$")
"         \| exe "normal! g'\"" | endif
" augroup END

" vim: ft=vim:et:sw=0:ts=2:sts=2:tw=78:fdm=marker:fmr={{{,}}}:
