fun! plugs#grepper#setup() abort
    let g:grepper = {
                \ 'dir': 'repo,file',
                \ 'simple_prompt': 1,
                \ 'searchreg': 1,
                \ 'stop': 50000,
                \ 'tools': ['rg', 'git'],
                \ 'rg': {
                \   'grepprg': 'rg ' .
                \       '--with-filename ' .
                \       '--no-heading ' .
                \       '--max-columns=200 ' .
                \       '--vimgrep ' .
                \       '--smart-case ' .
                \       '--color=never ' .
                \       '--follow ' .
                \       '--glob="!.git/**" ' .
                \       '--glob="!target/**" ' .
                \       '--glob="!node_modules/**" ' .
                \       '--glob="!ccache/**"'
                \   },
                \ 'grepformat': '%f:%l:%c:%m,%f:%l:%m',
                \ }

    " Grep project: operator
    nmap gs <Plug>(GrepperOperator)
    " Grep project: operator
    xmap gs <Plug>(GrepperOperator)
    " Grep project: word
    nmap gsw <Plug>(GrepperOperator)iw
    " Grep project: command
    nmap <Leader>rg :Grepper<CR>

    " augroup lmb__Grepper
    "     au!
    "     au User Grepper call setqflist([], 'r', {'context': {'bqf': {'pattern_hl': '\%#' . getreg('/')}}})
    " augroup END
endfun
