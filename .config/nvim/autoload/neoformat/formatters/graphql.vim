function! neoformat#formatters#graphql#enabled() abort
    return ['format_graphql', 'prettier']
endfunction

function! neoformat#formatters#zsh#format_graphql() abort
    let opts = get(g:, 'expand_opt', '')

    return {
            \ 'exe': 'format-graphql',
            \ 'args': ['--sort-fields=false', '--sort-arguments=false', '--sort-definitions=false'],
            \ 'stdin': 1,
            \ }
endfunction

function! neoformat#formatters#zsh#prettier() abort
    let opts = get(g:, 'expand_opt', '')

    return {
            \ 'exe': 'prettier',
            \ 'args': [],
            \ 'stdin': 1,
            \ }
endfunction
