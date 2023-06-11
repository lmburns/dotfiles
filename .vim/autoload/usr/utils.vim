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

function! usr#utils#GetFunctionFullName(plugin_name, function_name)
    let l:scriptnames = []

    " save previous content of register a
    let l:a = @a

    " capture the scriptname output in register a
    redir @a
    silent scriptnames
    redir END
    " split by new line
    let l:scriptnames = split(@a, '\n')

    " restore register a
    let @a = l:a

    " Filter the scriptnames with the plugin name / path
    call filter(l:scriptnames, 'v:val =~ "'.a:plugin_name.'"')

    " Accept only one answer
    if len(l:scriptnames) != 1
        echoerr("Please specify an existing unique filepath")
        echomsg("Your current result is:". l:scriptnames)
        return
    endif

    " Get the script number
    let l:scriptnumber = substitute(
                \ split(l:scriptnames[0])[0],
                \  ':', '', '')

    " Return the function full name
    return '<SNR>'.l:scriptnumber.'_'.a:function_name.'()'
endfunction

"-------------------------------------------------------------------------------
" usr#SID: Return the script ID <SID> of the sourced file.
" Returns:
"   SID - the SID of the script (string)
"-------------------------------------------------------------------------------
func! usr#utils#SID()
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfu

" Run the normal mode {command} from line {start} to {end}, opening any folds.
func! usr#utils#mark_visual(command, start, end) abort
    if a:start != line('.') | exec a:start | endif

    sil! exec printf('%d,%dfoldopen', a:start, a:end)

    if a:end > a:start
        exec 'normal!' a:command . (a:end - a:start) . 'jg_'
    else
        exec 'normal!' a:command . 'g_'
    endif
endfu

" Execute the normal mode {motion} and return the text that it marks. For this
" to work, the {motion} must include a visual mode key (`V`, `v`, or `gv`).
"
" Both the 'z' register and the original cursor position will be restored
" after the text is yanked.
func! usr#utils#get_motion(motion) abort
    let l:cursor = getpos('.')
    let l:reg = getreg('z')
    let l:type = getregtype('z')

    exec 'normal!' a:motion . '"zy'

    let l:text = @z

    call setreg('z', l:reg, l:type)
    call setpos('.', l:cursor)

    return l:text
endfu

" utils#get_var: Gets value of {var}, checking for a buffer override then a global value.
"   A [default] value may be provided.
func! usr#utils#get_var(var, ...) abort
    return get(b:, a:var, get(g:, a:var, get(a:000, 0, '')))
endfu

" utils#get: get a copy of an item or return a default value
"   @usage {list} {index} [default]
"     Get a copy of the item at {index} from |List| {list},
"     returning [default] if it is not available.
"   @usage {dict} {key} [default]
"     Get an copy of the item with key {key} from |Dictionary| {dict},
"     returning [default] if it is not available.
"   @usage {func} {what}
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
