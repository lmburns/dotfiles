function! Undotree_CustomMap()
    nmap <buffer> <C-u> <Plug>UndotreeUndo
    nunmap <buffer> u
endfunc

fun! plugs#undotree#setup()
    let g:undotree_SplitWidth = 45
    let g:undotree_SetFocusWhenToggle = 1
    let g:undotree_RelativeTimestamp = 1
    let g:undotree_ShortIndicators = 1
    let g:undotree_HelpLine = 0
    let g:undotree_WindowLayout = 3

    nnoremap <Leader>ut :UndotreeToggle<CR>
endfun

call plugs#undotree#setup()
