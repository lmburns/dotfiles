" ==============================================================================
" File:         autoload/jq.vim
" Author:       bfrg <https://github.com/bfrg>
" Website:      https://github.com/bfrg/vim-jq
" Last Change:  Aug 16, 2021
" License:      Same as Vim itself (see :h license)
" ==============================================================================

function! jq#jump(mode, pattern, flags, count) abort
    if a:mode == 'x'
        normal! gv
    endif
    let cnt = a:count
    mark '
    while cnt > 0
        call search(a:pattern, a:flags)
        let cnt = cnt - 1
    endwhile
endfunction

function! jq#cfile() abort
    if match(getline('.'), '^\s*\(#\+\)\?\s*\(import\|include\)') == -1
        return expand('<cfile>')
    endif

    let newfile = substitute(expand('<cfile>'), '\(\(\w\+/\)*\)\(\w\+\)$', '\1\3/\3', '')
    return !empty(findfile(expand('<cfile>')))
            \ ? expand('<cfile>')
            \ : !empty(findfile(newfile)) ? newfile : expand('<cfile>')
endfunction
