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

fun! api#buf_is_valid(bnr) abort
    return buflisted(a:bnr)
                \  && ("" ==# getbufvar(a:bnr, "&buftype") || "help" ==# getbufvar(a:bnr, "&buftype"))
                \  && a:bnr != bufnr("%")
                \  && -1 == index(tabpagebuflist(), a:bnr)
                \  && !(getbufvar(a:bnr, "&modified") && getbufvar(a:bnr, "&readonly"))
endfun

" Go to the previous window (or any other window if there is no 'previous' window).
fun! api#go_alt_win() abort
    let currwin = winnr()
    wincmd p
    if winnr() == currwin "window didn't change; no previous window.
        wincmd w
    endif
endf

func! api#get_alt_winnr() abort
    call s:switch_to_alt_win()
    let n = winnr()
    call s:switch_to_alt_win()
    return n
endf

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

fun! api#zz() abort
    let l1 = line('.')
    let l_count = line('$')
    if l1 == l_count
        keepjumps execute 'normal! ' . l1 . 'zb'
        return
    endif
    normal! zvzz
    let l1 = line('.')
    normal! L
    let l2 = line('.')
    if l2 + &scrolloff >= l_count
        keepjumps execute 'normal! ' . l2 . 'zb'
    endif
    if l1 != l2
        keepjumps normal! ``
    endif
endfun

func! api#abbr(cmd, match) abort
  return (getcmdtype() == ":" && matchstr(getcmdline(), '^'.a:cmd) == a:cmd)
        \ ? a:match
        \ : a:cmd
endf

"win_execute({id}, {command} [, {silent}])      String  execute {command} in window {id}
"win_findbuf({bufnr})                           List  find windows containing {bufnr}
"win_getid([{win} [, {tab}]])                 Number  get window ID for {win} in {tab}
"win_gettype([{nr}])                           String  type of window {nr}
"win_gotoid({expr})                               Number  go to window with ID {expr}
"win_id2tabwin({expr})                           List  get tab and window nr from window ID
"win_id2win({expr})                              Number  get window nr from window ID
"win_move_separator({nr})                        Number  move window vertical separator
"win_move_statusline({nr})                      Number  move window status line
"win_screenpos({nr})                               List  get screen position of window {nr}
"win_splitmove({nr}, {target} [, {options}])       Number  move window {nr} to split of {target}
"winbufnr({nr})                               Number  buffer number of window {nr}
"wincol()                                        Number  window column of the cursor
"winheight({nr})                                  Number  height of window {nr}
"winlayout([{tabnr}])                            List  layout of windows in tab {tabnr}
"winline()                                       Number  window line of the cursor
"winnr([{expr}])                               Number  number of current window
"winrestcmd()                                  String  returns command to restore window sizes
"winrestview({dict})                           none  restore view of current window
"winsaveview()                                Dict  save view of current window
"winwidth({nr})                              Number  width of window {nr}
