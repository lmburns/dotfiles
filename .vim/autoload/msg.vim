" Echo something
" @param hl {string} highlight group
" @param msg {string}
function! msg#echo(hl, msg) abort
    execute 'echohl' a:hl
    try
        echo a:msg
    finally
        echohl None
    endtry
endfunction

" Echo something to messages
" @param hl {string} highlight group
" @param msg {string}
function! msg#echomsg(hl, msg) abort
    execute 'echohl' a:hl
    " echomsg join(a:000, "\n")
    try
        for m in split(a:msg, "\n")
            echomsg m
        endfor
    finally
        echohl None
    endtry
endfunction

" Display an error message
" @param msg {string}
function! msg#error(msg) abort
    call msg#echomsg('ErrorMsg', a:msg)
endfunction

" Display a warning message
" @param msg {string}
function! msg#warn(msg) abort
    call msg#echomsg('WarningMsg', a:msg)
endfunction

function! msg#capture(command) abort
    try
        redir => out
        silent execute a:command
    finally
        redir END
    endtry
    return out
endfunction
