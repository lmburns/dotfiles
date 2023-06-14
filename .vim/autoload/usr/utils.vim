" Preserve: preserve cursor position when executing command
func! usr#utils#preserve(command)
    let s_report = &report
    let &report = 0

    let last_search = getreg('/')
    if exists('*winsaveview')
        let oldview = winsaveview()
    else
        " [bufnum, lnum, col, off]
        let pos = getpos(".")
    endif

    exec 'keepj keepp keepm ' . a:command

    if exists('oldview')
        if oldview != winsaveview()
            redraw
        endif
        call winrestview(oldview)
    else
        let lastline = line("$")
        if pos[1] > lastline
            let pos[1] = lastline
        endif
        call setpos('.', pos)
    endif
    call setreg('/', last_search)
    let &report = s_report
endfu

" Follow a symbolic link
func! usr#utils#follow_symlink(...) abort
    let fname = fnamemodify(a:0 ? a:1 : expand('%'), ':p')
    if getftype(fname) != 'link'
        return
    endif
    execute 'keepalt file ' . fnameescape(resolve(fname))

    if a:2
        execute a:2
    endif
endfu

func! usr#utils#clean_empty_buf()
    let bufnr_list = []
    for buf in getbufinfo({'buflisted': 1})
        if !buf.changed && empty(buf.name)
            call add(bufnr_list, buf.bufnr)
        endif
    endfor
    if !empty(bufnr_list)
        execute 'bwipeout ' . join(bufnr_list)
    endif
endfu

"  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

" Get the <SID> of a {file}
" @param file {string}
" @return {Dictionary}
func! usr#utils#get_sid(file) abort
    let sids = getscriptinfo(#{name: a:file})
    return len(sids) == 1 ? sids[0] : sids
endfunc

" Get the value of {var} or return a default value.
" Checks for a buffer override before getting the global value.
" @param var {string} variable to get
" @param ... {any} default variable
" @return {any}
func! usr#utils#get_var(var, ...) abort
    return get(b:, a:var, get(g:, a:var, get(a:000, 0, '')))
endfu

" Get a copy of an item or return a default value.
" @usage {list} {index} [default]
"     Get a copy of the item at {index} from |List| {list},
"     returning [default] if it is not available.
" @usage {dict} {key} [default]
"     Get an copy of the item with key {key} from |Dictionary| {dict},
"     returning [default] if it is not available.
" @usage {func} {what}
"     Get an item {what} from Funcref {func}.
func! usr#utils#get(expr, index, ...) abort
    if type(a:expr) == v:t_func
        return get(a:expr, a:index)
    elseif a:0
        return deepcopy(get(a:expr, a:index, a:1))
    else
        return deepcopy(get(a:expr, a:index))
    endif
endfu
