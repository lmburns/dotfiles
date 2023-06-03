fun! usr#qf#toggle(type) abort
    let l:w = winnr('$')
    execute 'sil '. s:toggle_window_commands[a:type].close
    if l:w == winnr('$')
        execute 'sil '. s:toggle_window_commands[a:type].open
        setl nowrap whichwrap=b,s
    endif
endfun

if !exists('s:toggle_window_commands')
    let s:toggle_window_commands =
                \ {
                \   'quickfix': { 'close': 'cclose', 'open': 'copen' },
                \   'location': { 'close': 'lclose', 'open': 'lopen' }
                \ }
    lockvar s:toggle_window_commands
endif

fun! usr#qf#close() abort
    let loc_winid = getloclist(0, {'winid': 0}).winid
    if loc_winid == 0
        cclose
    else
        let qf_winid = getqflist({'winid': 0}).winid
        if qf_winid == 0
            lclose
        endif
    endif
endfun

fun! usr#qf#is_type(winnr) abort
    let info = get(getwininfo(win_getid(a:winnr)), 0, {})
    if get(info, 'loclist', 0)
        " return 'loc'
        return 2
    elseif get(info, 'quickfix', 0)
        " return 'qf'
        return 1
    endif
    return 0
endfun

func! usr#qf#is_qf(winnr)
    " if getwinvar(a:winnr, "&filetype") == "qf"
    return usr#qf#is_type(a:winnr) == 1
endfun

func! usr#qf#is_loc(winnr)
    return usr#qf#is_type(a:winnr) == 2
endfun

func! usr#qf#qf_is_open() abort
    for winnr in range(1, winnr('$'))
        if usr#qf#is_qf(winnr)
            return 1
        endif
    endfor
    return 0
endfun

func! usr#qf#loc_is_open(winn) abort
    let loclist = getloclist(a:winn)
    for winnr in range(1, winnr('$'))
        if usr#qf#is_loc(winnr) && loclist ==# getloclist(winnr)
            return 1
        endif
    endfor
    return 0
endfunc
