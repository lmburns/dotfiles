func! Undotree_CustomMap()
    nmap <buffer> <C-u> <Plug>UndotreeUndo
    nunmap <buffer> u
endfu

func s:undo_toggle()
    call undotree#UndotreeToggle()
    call s:clean_undo_file()
endfu

func s:clean_undo_file()
    for undo_file in split(globpath(&undodir, '*'), '\n')
        let file_with_per = substitute(undo_file, &undodir . '/', '', '')
        let file = substitute(file_with_per, '%', '/', 'g')
        if empty(glob(file))
            call delete(undo_file)
        end
    endfor
endfu

func! plugs#undotree#setup()
    let g:undotree_SplitWidth = 45
    let g:undotree_SetFocusWhenToggle = 1
    let g:undotree_RelativeTimestamp = 1
    let g:undotree_ShortIndicators = 1
    let g:undotree_HelpLine = 0
    let g:undotree_WindowLayout = 3

    com! -nargs=0 UndotreeToggle call s:undo_toggle()
    nnoremap <Leader>ut <Cmd>UndotreeToggle<CR>
endfu

call plugs#undotree#setup()
