setl foldcolumn=2
setl signcolumn=no
setl foldmethod=syntax
setl foldtext=fugitive#Foldtext()
setl nolist
setl cc=
setl nonu nornu

" setl foldmethod=expr
" setl foldexpr=DiffFold()

function! DiffFold()
    let line = getline(v:lnum)
    if line =~# '^\(diff\|index\)' " file
        return '>1'
    elseif line =~# '^--- .*$'
        return '>1'
    elseif line =~# '^==== .*$'
        return '>1'
    elseif line =~# '^@@' " hunk
        return '>2'
    elseif line =~# '^\*\*\* \d\+,\d\+ \*\*\*\*$' " context: file1
        return '>2'
    elseif line =~# '^--- \d\+,\d\+ ----$' " context: file2
        return '>2'
    else
        return '='
    endif
endfunction
