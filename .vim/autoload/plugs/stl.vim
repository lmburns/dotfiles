func! plugs#stl#setup() abort
  " jump mapping
  nmap ,1 <Plug>lightline#bufferline#go(1)
  nmap ,2 <Plug>lightline#bufferline#go(2)
  nmap ,3 <Plug>lightline#bufferline#go(3)
  nmap ,4 <Plug>lightline#bufferline#go(4)
  nmap ,5 <Plug>lightline#bufferline#go(5)
  nmap ,6 <Plug>lightline#bufferline#go(6)
  nmap ,7 <Plug>lightline#bufferline#go(7)
  nmap ,8 <Plug>lightline#bufferline#go(8)
  nmap ,9 <Plug>lightline#bufferline#go(9)
  nmap ,0 <Plug>lightline#bufferline#go(10)

  " kill mapping
  nmap ;1 <Plug>lightline#bufferline#delete(1)
  nmap ;2 <Plug>lightline#bufferline#delete(2)
  nmap ;3 <Plug>lightline#bufferline#delete(3)
  nmap ;4 <Plug>lightline#bufferline#delete(4)
  nmap ;5 <Plug>lightline#bufferline#delete(5)
  nmap ;6 <Plug>lightline#bufferline#delete(6)
  nmap ;7 <Plug>lightline#bufferline#delete(7)
  nmap ;8 <Plug>lightline#bufferline#delete(8)
  nmap ;9 <Plug>lightline#bufferline#delete(9)
  nmap ;0 <Plug>lightline#bufferline#delete(10)

  let s:nbsp = ' '
  let g:lightline#bufferline#filename_modifier = ":t".s:nbsp
  let g:lightline#bufferline#shorten_path      = 1
  let g:lightline#bufferline#show_number       = 2
  let g:lightline#bufferline#min_buffer_count  = 0
  let g:lightline#bufferline#unnamed           = '[No Name]'
  let g:lightline#bufferline#read_only         = '  '
  let g:lightline#bufferline#modified          = " + "
  let g:lightline#bufferline#enable_devicons = 1
  let g:lightline#bufferline#unicode_symbols = 1
  let g:lightline#bufferline#number_map = {
        \ 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴',
        \ 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹'}
  " \ 0: '₀', 1: '₁', 2: '₂', 3: '₃', 4: '₄',
  " \ 5: '₅', 6: '₆', 7: '₇', 8: '₈', 9: '₉'}
  let g:lightline#bufferline#unicode_symbols = 1

  let g:lightline#gitdiff#indicator_added = ': '
  let g:lightline#gitdiff#indicator_deleted = ': '
  let g:lightline#gitdiff#indicator_modified = 'ﰲ: '
  let g:lightline#gitdiff#separator = ' '
  " let g:lightline#gitdiff#show_empty_indicators = 1
  " ]]] === lightline-buffer ===

  function! CocDiagnosticError() abort "[[[
    let info = get(b:, 'coc_diagnostic_info', {})
    return get(info, 'error', 0) ==# 0 ? '' : ' ' . info['error'] "   
  endfunction "]]]

  function! CocDiagnosticWarning() abort "[[[
    let info = get(b:, 'coc_diagnostic_info', {})
    return get(info, 'warning', 0) ==# 0 ? '' : ' ' . info['warning'] "      !
  endfunction "]]]

  function! CocDiagnosticOK() abort "[[[
    let info = get(b:, 'coc_diagnostic_info', {})
    return get(info, 'error', 0) ==# 0 && get(info, 'warning', 0) ==# 0 ? '' : '' "  
  endfunction "]]]

  function! CocStatus() abort "[[[
    return get(g:, 'coc_status', '')
  endfunction "]]]

  function! GitGlobal() abort "[[[
    if exists('*FugitiveHead')
      let branch = FugitiveHead()
      if branch ==# ''
        return ' ' . fnamemodify(getcwd(), ':t')
      else
        return branch . ' '
      endif
    endif
    return ''
  endfunction "]]]

  function! DeviconsFiletype() "[[[
    return winwidth(0) > 80 ? (strlen(&filetype) ? WebDevIconsGetFileTypeSymbol() . ' ' . &filetype : 'no ft') : ''
    " return winwidth(0) > 100 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
  endfunction "]]]

  function! TabNum(n) abort "[[[
    return a:n." \ue0bb"
  endfunction "]]]

  " FIX: function
  function! NumBufs() abort "[[[
    " let num = len(getbufinfo({'buflisted':1}))
    " let hid = len(filter(getbufinfo({'buflisted':1}), 'empty(v:val.windows)'))
    return len(filter(range(1, bufnr('$')), 'buflisted(v:val)'))
    " return hid ? num-hid."+".hid : num
  endfunction "]]]

  " function! FileSize() abort "[[[
  "   let [ bytes, units, i ] = [ getfsize(expand(@%)), ['', 'Ki', 'Mi', 'Gi'], 0 ]
  "   while bytes >= 1024 | let bytes = bytes / 1024.0 | let i += 1 | endwhile
  "   return printf((i ? "~%.1f" : "%d")." %sB", bytes, units[i])
  " endfunction "]]]

  let g:ll_blacklist = '\v(help|nerdtree|quickmenu|startify|undotree|neoterm|'
        \ . 'fugitive|netrw|vim-plug|floaterm|qf)'

  function! FileSize() abort " [[[
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
  endfunction "]]]

  function! LightLineReadonly() abort "[[[
    return &readonly && &filetype !~# g:ll_blacklist ? '' : ''
  endfunction "]]]

  function! LightlineFilename() abort "[[[
    let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
    let modified = &modified ? ' +' : ''
    return winwidth(0) > 40 ? filename . modified : ''
  endfunction "]]]

  function! LightlineGitStatus() abort "[[[
    let status = get(b:, 'coc_git_status', '')
    return winwidth(0) > 80 ? status : ''
  endfunction "]]]

  function! LightlineFileEncoding() "[[[
    " only show the file encoding if it's not 'utf-8'
    return &fileencoding == 'utf-8' ? '' : &fileencoding
  endfunction "]]]

  function! NearestMethodOrFunction() abort "[[[
    return get(b:, 'vista_nearest_method_or_function', '')
  endfunction "]]]

  autocmd VimEnter * call vista#RunForNearestMethodOrFunction()

  set showtabline=2
  let g:lightline = {}
  " let g:lightline.colorscheme = 'overcast'
  let g:lightline.colorscheme = 'gruvbox_material'
  " let g:lightline.colorscheme = 'everforest'
  " let g:lightline.colorscheme = 'miramare'
  " let g:lightline.colorscheme = 'nightowl'
  " let g:lightline.colorscheme = 'spaceduck'
  " let g:lightline.colorscheme = 'sonokai'
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
  " \ 'readonly': 'lightline#tab#readonly',
  " \ 'filename': 'lightline#tab#filename',
  " \ 'modified': 'lightline#tab#modified',
  let g:lightline.tab_component_function = {
        \ 'tabnum': 'TabNum',
        \ 'filename': 'LightlineFilename',
        \ }
  " \ 'fileencoding': '%{&fenc!=#""?&fenc:&enc}',
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
endf
