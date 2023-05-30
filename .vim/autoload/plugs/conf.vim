fun! plugs#conf#suda() abort
    nnoremap <silent> <Leader>W :SudaWrite<CR>
endfun

fun! plugs#conf#splitjoin() abort
    let g:splitjoin_join_mapping = 'gS'
    let g:splitjoin_split_mapping = 'gJ'
endfun

fun! plugs#conf#linediff() abort
    nnoremap <silent> <Leader>ld :Linediff<CR>
    xnoremap <silent> <Leader>ld :Linediff<CR>
    nnoremap <silent> <Leader>lD :LinediffReset<CR>
    xnoremap <expr> D (mode() ==# "V" ? ':Linediff<CR>' : 'D')
    cnoreabbrev ldr LinediffReset
endfun

fun! plugs#conf#eregex() abort
    let g:eregex_default_enable = 0
    let g:eregex_forward_delim = "/"
    let g:eregex_backward_delim = "?"

    " Toggle eregex
    nnoremap <Leader>es <Cmd>call eregex#toggle()<CR>
    " Toggle eregex
    nnoremap ,/ <Cmd>call eregex#toggle()<CR>
    " Global replace (E2v)
    nnoremap <Leader>S :%S//g<Left><Left>
endfun

fun! plugs#conf#caser() abort
    let g:caser_prefix = 'cr'
    nmap crs <Plug>CaserSnakeCase
    nmap crd <Plug>CaserDotCase
    nmap crS <Plug>CaserSentenceCase
endfun

fun! plugs#conf#replace() abort
    nmap s  <Plug>ReplaceOperator
    nmap ss siL
endfun

fun! plugs#conf#exchange() abort
    nmap sx <Plug>(Exchange)
    nmap sS <Plug>(ExchangeLine)
    nmap sxc <Plug>(ExchangeClear)
    xmap X <Plug>(Exchange)
endfun
