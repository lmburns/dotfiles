function! neoformat#formatters#lua#luafmtext() abort
    return {
        \ 'exe': 'lua-fmt-ext',
        \ 'args': ['--stdin'],
        \ 'stdin': 1,
        \ }
endfunction

function! neoformat#formatters#lua#luafmt() abort
    return {
        \ 'exe': 'luafmt',
        \ 'args': ['--stdin'],
        \ 'stdin': 1,
        \ }
endfunction

function! neoformat#formatters#lua#luaformat() abort
    return {
        \ 'exe': 'lua-format'
        \ }
endfunction

function! neoformat#formatters#lua#stylua() abort
    return {
        \ 'exe': 'stylua',
        \ 'args': ['--search-parent-directories', '--stdin-filepath', '"%:p"', '--', '-'],
        \ 'stdin': 1,
        \ }
endfunction
