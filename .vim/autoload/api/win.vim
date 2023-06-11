" Go to window holding given buffer (by number)
" Prefers current window; if its buffer number doesn't match,
" then will try from topleft to bottom right
func! api#win##goto_winbufnr(bufnr) abort
    if winbufnr(0) ==# a:bufnr
        return
    endif
    winc t
    let first=1
    while winbufnr(0) != a:bufnr && (first || winnr() != 1)
        winc w
        let first= 0
    endwhile
endf

" Find windows opened in the {bufnr}
func! api#win#in_buf(bufnr)
    let cnt = 0
    let winnum = 1
    while 1
        let bufnum = winbufnr(winnum)
        if bufnum < 0
            break
        endif
        if bufnum ==# a:bufnr
            let cnt = cnt + 1
        endif
        let winnum = winnum + 1
    endwhile

    return cnt
endf

" Find the `winnr` of the first normal window
func! api#win#first_usable()
    let i = 1
    while i <= winnr("$")
        let bnum = winbufnr(i)
        if bnum != -1 && getbufvar(bnum, '&buftype') ==# ''
        \ && !getwinvar(i, '&previewwindow')
        \ && (!getbufvar(bnum, '&modified') || &hidden)
            return i
        endif

        let i += 1
    endwhile
    return -1
endf

" Go to the previous window (winnr) (or any other window, if none)
func! api#win#goto_alt() abort
    let currwin = winnr()
    wincmd p
    if winnr() == currwin "window didn't change; no previous window.
        wincmd w
    endif
endf

func! api#win#get_alt_winnr() abort
    call api#win#goto_alt()
    let n = winnr()
    call api#win#goto_alt()
    return n
endf

"win_execute({id}, {command} [, {silent}])     String  execute {command} in window {id}
"win_findbuf({bufnr})                          List  find windows containing {bufnr}
"win_getid([{win} [, {tab}]])                  Number  get window ID for {win} in {tab}
"win_gettype([{nr}])                           String  type of window {nr}
"win_gotoid({expr})                            Number  go to window with ID {expr}
"win_id2tabwin({expr})                         List  get tab and window nr from window ID
"win_id2win({expr})                            Number  get window nr from window ID
"win_move_separator({nr})                      Number  move window vertical separator
"win_move_statusline({nr})                     Number  move window status line
"win_screenpos({nr})                           List  get screen position of window {nr}
"win_splitmove({nr}, {target} [, {options}])   Number  move window {nr} to split of {target}
"winbufnr({nr})                                Number  buffer number of window {nr}
"wincol()                                      Number  window column of the cursor
"winheight({nr})                               Number  height of window {nr}
"winlayout([{tabnr}])                          List  layout of windows in tab {tabnr}
"winline()                                     Number  window line of the cursor
"winnr([{expr}])                               Number  number of current window
"winrestcmd()                                  String  returns command to restore window sizes
"winrestview({dict})                           none  restore view of current window
"winsaveview()                                 Dict  save view of current window
"winwidth({nr})                                Number  width of window {nr}
