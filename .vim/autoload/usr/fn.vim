let s:V = vital#vimrc#new()
let s:Msg = s:V.import('Vim.Message')

fun! usr#fn#trim_whitespace(...)
    " call usr#utils#preserve('%s/\\\@<!\s\+$//e')

    " Delete trailing blank lines at end of file
    " call usr#utils#preserve('0;/^\%(\n*.\)\@!/,$d')

    " End of lines
    call usr#utils#preserve('%s/\s\+$//ge')
    " Delete trailing blank lines
    call usr#utils#preserve('%s#\($\n\s*\)\+\%$##e')
endfun

fun! s:profile() abort
    profile dump
    profile stop
    call s:Msg.warn("profiling has stopped")
    nunmap ;p
    nmap ;p <Cmd>call usr#fn#Profile()<CR>
endf

fun! usr#fn#Profile() abort
    call s:Msg.warn("profiling has begun")
    profile start /tmp/profile-vim.log
    " profile! file **
    profile file *
    profile func *
    nmap ;p <Cmd>call <SID>profile()<CR>
endf

fun! usr#fn#range_search(direction)
    call inputsave()
    let g:srchstr = input(a:direction)
    call inputrestore()
    if strlen(g:srchstr) > 0
        let g:srchstr = g:srchstr.
            \ '\%>'.(line("'<")-1).'l'.
            \ '\%<'.(line("'>")+1).'l'
    else
        let g:srchstr = ''
    endif
endfu

fun! usr#fn#synstack()
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfun

":verbose hi <name>
" SyntaxQuery: Display the syntax stack at current cursor position
fun! usr#fn#syntax_query() abort
    for id in synstack(line("."), col("."))
        execute 'hi' synIDattr(id, "name")
    endfor
endfun

fun! usr#fn#ClearRegisters()
    let l:regs='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-="*+'
    let l:i=0
    while (l:i<strlen(l:regs))
        exec 'let @'.l:regs[l:i].'=""'
        let l:i=l:i+1
    endwhile
endfun

fun! usr#fn#ToggleLastChar(pat)
    let view = winsaveview()
    try
        keepj keepp exe 's/\([^'.escape(a:pat,'/').']\)$\|^$/\1'.escape(a:pat,'/').'/'
    catch /^Vim\%((\a\+)\)\=:E486: Pattern not found/
        keepj keepp exe 's/'.escape(a:pat, '/').'$//'
    finally
        call winrestview(view)
    endtry
endfun

" DiffSaved: Show diff since last save
fun! usr#fn#DiffSaved()
    let filetype = &filetype
    diffthis
    vnew | r # | normal! 1Gdd
    diffthis
    exe 'setl bt=nofile bh=wipe nobl noswf ro ft=' . filetype
endfun

" ExecuteMacroVisual: exec a macro in visual mode
fun! usr#fn#ExecuteMacroVisual()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
endfun

" GoGithub: open in browser
fun! usr#fn#GoGithub()
    let s:repo = matchstr(expand('<cWORD>'), '\v[0-9A-Za-z\-\.\_]+/[0-9A-Za-z\-\.\_]+')
    if empty(s:repo)
        echo 'GoGithub: No repository found.'
    else
        let s:url = 'https://github.com/' . s:repo
        " call netrw#BrowseX(s:url, 0)
        call openbrowser#open(s:url)
    end
endfun

" ExecuteBuffer: execute current buffer
fun! usr#fn#ExecuteBuffer()
    if !empty(expand('%'))
        write
        call system('chmod +x '.expand('%'))
        silent e
        vsplit | terminal ./%
    else
        echohl WarningMsg
        echo 'Save the file first'
        echohl None
    endif
endfun

" TmuxCopyMode: toggle the signcolumn and numbers to copy text easier
fun! usr#fn#TmuxCopyMode()
    setlocal number!
    setlocal relativenumber!
    if &signcolumn ==? 'no'
        setlocal signcolumn=yes:1
        setlocal foldcolumn=1
    else
        setlocal signcolumn=no
        setlocal foldcolumn=0
    endif
endfun

" TermToggle: create a toggle-able terminal
let g:term_buf = 0
let g:term_win = 0
function! usr#fn#TermToggle(height)
    if win_gotoid(g:term_win)
        hide
    else
        botright new
        exec "resize " .. a:height
        try
            exec "buffer " .. g:term_buf
        catch
            call termopen("zsh", {"detach": 0})
            let g:term_buf = bufnr("")
            set nonumber
            set norelativenumber
            set signcolumn=no
        endtry
        startinsert!
        let g:term_win = win_getid()
    endif
endfunction

" PreserveClipboard: Fixes clearing of clipboard when using copyq [[[
if executable('xsel')
    function! usr#fn#PreserveClipboard()
        call system('xsel -ib', getreg('+'))
    endfunction
    function! usr#fn#PreserveClipboadAndSuspend()
        call usr#fn#PreserveClipboard()
        suspend
    endfunction
endif
