function! neoformat#formatters#zsh#enabled() abort
    return ['expand']
endfunction

function! neoformat#formatters#zsh#expand() abort
    let opts = get(g:, 'expand_opt', '')

    return {
            \ 'exe': 'expand',
            \ 'args': ['-t 2'],
            \ 'stdin': 1,
            \ }
endfunction
