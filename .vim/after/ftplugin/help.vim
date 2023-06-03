setl nonumber norelativenumber nolist
setl concealcursor=c
setl colorcolumn=+1
setl signcolumn=yes
setl textwidth=85
setl formatexpr=HelpFormatExpr()

if exists('*HelpFormatExpr')
  finish
endif


fun! s:right_align() abort
  let text = matchstr(getline('.'), '^\s*\zs.\+\ze\s*$')
  let remainder = (&l:textwidth + 1) - len(text)
  call setline(line('.'), repeat(' ', remainder).text)
  undojoin
endfun


fun! HelpFormatExpr() abort
  if mode() ==# 'i' || v:char != ''
    return 1
  endif

  let line = getline(v:lnum)
  if line =~# '^=\+$'
    normal! macc
    normal! 78i=
    normal! `a
    undojoin
    return
  elseif line =~# '^\k\%(\k\|\s\)\+\s*\*\%(\k\|-\)\+\*\s*'
    let [header, link] = split(line, '^\k\%(\k\|\s\)\+\zs\s*')
    let header = substitute(header, '^\_s*\|\_s*$', '', 'g')
    let remainder = (&l:textwidth + 1) - len(header) - len(link)
    let line = header.repeat(' ', remainder).link
    call setline(v:lnum, line)
    return
  endif

  return 1
endfun

nnoremap <silent><buffer> ;fr :<c-u>call <sid>right_align()<cr>

" Go to definition
nmap <silent><buffer> <CR> <C-]>
" Go to prev buffer
nmap <silent><buffer> <BS> <C-^>
" Go to next tag
nmap <silent><buffer> ]f ta
" Go to prev tag
nmap <silent><buffer> [f <C-t>

" Next cword occurrence
nmap <silent><buffer> ]x <Cmd>call search(expand('<cword>'), 'w')<CR>
" Prev cword occurrence
nmap <silent><buffer> [x <Cmd>call search(expand('<cword>'), 'wb')<CR>
" Next cWORD occurrence
nmap <silent><buffer> ]X <Cmd>call search(expand('<cWORD>'), 'w')<CR>
" Prev cWORD occurrence
nmap <silent><buffer> [X <Cmd>call search(expand('<cWORD>'), 'wb')<CR>
" Next 'quoted word'
nmap <silent><buffer> ]w <Cmd>call search('''\l\{2,}''', 'w')<CR>
" Prev 'quoted word'
nmap <silent><buffer> [w <Cmd>call search('''\l\{2,}''', 'wb')<CR>

" Next heading
nmap <silent><buffer> ) <Cmd>call search('^==============================', 'w')<Bar>norm ]]<CR>
" Prev heading
nmap <silent><buffer> ( <Cmd>call search('^==============================', 'wb')<Bar>norm ]]<CR>

" Next *link*
nmap <silent><buffer> ]] <Cmd>call search('\*\S\{-}\*', 'w')<CR>
" Prev *link*
nmap <silent><buffer> [[ <Cmd>call search('\*\S\{-}\*', 'wb')<CR>
" Next |link|
nmap <silent><buffer> } <Cmd>call search('<Bar>\S\{-}<Bar>', 'w')<CR>
" Prev |link|
nmap <silent><buffer> <buffer> { <Cmd>call search('<Bar>\S\{-}<Bar>', 'wb')<CR>
" Next blank line
nmap <silent><buffer><nowait> > }
" Prev blank line
nmap <silent><buffer><nowait> < {

" Helptags to quickfix
nmap <silent><buffer> gX <Cmd>vimgrep /\v.*\*\S+\*$/j %<Bar>copen<CR>
" Helptags to loclist
nmap <silent><buffer> gx <Cmd>lvimgrep /\v.*\*\S+\*$/j %<Bar>lopen<CR>

function! s:format_helptags() abort
  let l:view = winsaveview()
  %sub/\v(.{-})(\s{2,})(\*.*\*)/\=submatch(1) . repeat(" ", 48 - len(submatch(1))) . submatch(3)
  noh
  call winrestview(l:view)
endfunction

nnoremap <buffer> <leader>ff <Cmd>call <sid>format_helptags()<CR>
