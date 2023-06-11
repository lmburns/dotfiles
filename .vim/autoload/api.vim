" Nvim API type functions (for vim)

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
