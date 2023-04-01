function! AdjustWindowHeight(minheight, maxheight)
  exe max([a:minheight, min([line('$') + 1, a:maxheight])]) . 'wincmd _'
endfunction

" -- Quit vim if the last window is qf
" vim.cmd[[autocmd! BufEnter <buffer> if winnr('$') < 2| q | endif]]

" fix last window is floating with hl and blend
if &winhl != ''
    setlocal winhl=
endif

if &winbl
    setlocal winbl=0
endif

setl so=2
setl nospell
setl nolist

noremap <buffer> qa <Cmd>q<CR><Cmd>qa<CR>
nnoremap <buffer> { :colder<CR>
nnoremap <buffer> } :cnewer<CR>

augroup QuickfixAutocmds
  autocmd!
  autocmd BufReadPost quickfix call AdjustWindowHeight(2, 30)
augroup END

nnoremap <buffer> H <Cmd>colder<CR>
nnoremap <buffer> L <Cmd>cnewer<CR>

" setlocal nobuflisted " qf buffers should not pop up when doing :bn or :bp
