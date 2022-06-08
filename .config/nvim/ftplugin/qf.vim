augroup QuickfixAutocmds
  autocmd!
  autocmd BufReadPost quickfix call AdjustWindowHeight(2, 30)
augroup END

function! AdjustWindowHeight(minheight, maxheight)
  exe max([a:minheight, min([line('$') + 1, a:maxheight])]) . 'wincmd _'
endfunction

nnoremap <buffer> H <Cmd>colder<CR>
nnoremap <buffer> L <Cmd>cnewer<CR>

" setlocal nobuflisted " qf buffers should not pop up when doing :bn or :bp
