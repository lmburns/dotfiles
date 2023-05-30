" Nvim API type functions (for vim)

fun! api#buf_line_count(bufnr) abort
  if bufnr('%') == a:bufnr
    return line('$')
  endif
  if exists('*getbufinfo')
    let info = getbufinfo(a:bufnr)
    if empty(info)
      return 0
    endif
    " vim 8.1 has getbufinfo but no linecount
    if has_key(info[0], 'linecount')
      return info[0]['linecount']
    endif
  endif
  return len(getbufline(a:bufnr, 1, '$'))
endfun

" GoWinBufnr: go to window holding given buffer (by number) {{{2
"   Prefers current window; if its buffer number doesn't match,
"   then will try from topleft to bottom right
fun! api#goto_winbufnr(bufnum)
  if winbufnr(0) == a:bufnum
    return
  endif
  winc t
  let first=1
  while winbufnr(0) != a:bufnum && (first || winnr() != 1)
    winc w
    let first= 0
  endwhile
endfun
