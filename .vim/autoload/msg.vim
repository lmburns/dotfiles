function! msg#echo(hl, msg) abort
    execute 'echohl' a:hl
    try
        echo a:msg
    finally
        echohl None
    endtry
endfunction

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

function! msg#error(msg) abort
    call msg#echomsg('ErrorMsg', a:msg)
endfunction

function! msg#warn(msg) abort
    call msg#echomsg('WarningMsg', a:msg)
endfunction
