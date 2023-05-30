function! autonumber#off() abort
    setl norelativenumber number
endfunction

function! autonumber#relative() abort
    let w:autonumber_mode = 0
    call autonumber#reset()
endfunction

function! autonumber#numbers() abort
    let w:autonumber_mode = 1
    call autonumber#reset()
endfunction

function! autonumber#hidden() abort
    let w:autonumber_mode = 2
    call autonumber#reset()
endfunction

function! autonumber#toggle() abort
    if w:autonumber_mode == 1
        let w:autonumber_lock = v:true
        call autonumber#hidden()
    elseif w:autonumber_mode == 2
        let w:autonumber_lock = v:false
        call autonumber#relative()
    elseif w:autonumber_mode == 0
        let w:autonumber_lock = v:false
        call autonumber#numbers()
    endif
endfunction

function! autonumber#reset() abort
    let w:autonumber_mode = get(w:, 'autonumber_mode', 0)
    let w:autonumber_lock = get(w:, 'autonumber_lock', v:false)
    let g:autonumber_exclude_filetype = get(g:, 'autonumber_exclude_filetype', [])
    let g:autonumber_exclude_buftype = get(g:, 'autonumber_exclude_buftype', [])

    if w:autonumber_lock
        return
    endif

    if w:autonumber_mode == 0
        setl relativenumber number
    elseif w:autonumber_mode == 1
        call autonumber#off()
        setl number
    elseif w:autonumber_mode == 2
        call autonumber#off()
        setl nonumber
    endif

    if index(g:autonumber_exclude_filetype, &ft) >= 0
        setl norelativenumber nonumber
    endif
    if index(g:autonumber_exclude_buftype, &bt) >= 0
        setl norelativenumber nonumber
    endif
endfunction

function! autonumber#enable() abort
    let g:autonumber_enable = v:true
    let w:autonumber_lock = v:false
    call autonumber#relative()

    "   au BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
    "   au BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
    augroup lmb__RnuColumn
        autocmd!
        autocmd FocusLost,InsertEnter,WinLeave * :call autonumber#numbers()
        autocmd FocusGained,InsertLeave,VimEnter,WinEnter * :call autonumber#relative()
        autocmd CmdlineEnter /,\? :call autonumber#numbers() | redraw
        autocmd CmdlineLeave /,\? :call autonumber#relative()
        autocmd BufNewFile,BufReadPost,FileType * :call autonumber#reset()
    augroup END
endfunction

function! autonumber#disable() abort
    call autonumber#hidden()
    let w:autonumber_lock = v:true
    let g:autonumber_enable = v:false
    autocmd! lmb__RnuColumn
endfunction

function! autonumber#toggleAll() abort
    if get(g:, 'autonumber_enable', v:false) == 1
        call autonumber#disable()
    else
        call autonumber#enable()
    endif
endfunction
