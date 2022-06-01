nnoremap <buffer><silent> <M-i> :<C-u>call search('<Bar>.\{-}<Bar>', 'w')<CR>
nnoremap <buffer><silent> <M-o> :<C-u>call search('<Bar>.\{-}<Bar>', 'wb')<CR>

nnoremap <buffer> <CR> <C-]>
" Go to next occurrence of word
nnoremap <buffer> <A-CR> /<C-R><C-W><CR>:nohl<CR>

" Next link
nnoremap <buffer> <A-]> /\v\<Bar>[^<Bar>]+\<Bar><CR>
nnoremap <buffer> <A-[> ?\v\<Bar>[^<Bar>]+\<Bar><CR>
