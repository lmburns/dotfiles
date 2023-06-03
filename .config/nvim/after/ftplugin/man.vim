setl nowrap

" Send all flag options to loclist
nnoremap <buffer> gx <Cmd>lvimgrep /\v^\s*--?\w+/j %<Bar>lopen<CR>
