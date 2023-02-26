setl so=2

" -- Quit vim if the last window is qf
" vim.cmd[[autocmd! BufEnter <buffer> if winnr('$') < 2| q | endif]]

" fix last window is floating with hl and blend
if &winhl != ''
    setlocal winhl=
endif

if &winbl
    setlocal winbl=0
endif

setlocal nospell

noremap <buffer> qa <Cmd>q<CR><Cmd>qa<CR>
nnoremap <buffer> { :colder<CR>
nnoremap <buffer> } :cnewer<CR>
