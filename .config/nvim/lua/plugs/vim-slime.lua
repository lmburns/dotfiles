require("common.utils")

g.slime_target = "neovim"
g.syntastic_python_pylint_post_args="--max-line-length=120"

cmd [[
  if !empty(glob('$XDG_DATA_HOME/pyenv/shims/python3'))
    let g:python3_host_prog = glob('$XDG_DATA_HOME/pyenv/shims/python')
  endif

  augroup repl
    autocmd!
    autocmd FileType python
      \ xmap <buffer> ,l <Plug>SlimeRegionSend|
      \ nmap <buffer> ,l <Plug>SlimeLineSend|
      \ nmap <buffer> ,p <Plug>SlimeParagraphSend|
      \ nnoremap <silent> ✠ :TREPLSendLine<CR><Esc><Home><Down>|
      \ inoremap <silent> ✠ <Esc>:TREPLSendLine<CR><Esc>A|
      \ xnoremap <silent> ✠ :TREPLSendSelection<CR><Esc><Esc>
      \ nnoremap <Leader>rF :T ptpython<CR>|
      \ nnoremap <Leader>rf :T ipython --no-autoindent --colors=Linux --matplotlib<CR>|
      \ nmap <buffer> <Leader>r<CR> :VT python %<CR>|
      \ nnoremap ,rp :SlimeSend1 <C-r><C-w><CR>|
      \ nnoremap ,rP :SlimeSend1 print(<C-r><C-w>)<CR>|
      \ nnoremap ,rs :SlimeSend1 print(len(<C-r><C-w>), type(<C-r><C-w>))<CR>|
      \ nnoremap ,rt :SlimeSend1 <C-r><C-w>.dtype<CR>|
      \ nnoremap 223 ::%s/^\(\s*print\)\s\+\(.*\)/\1(\2)<CR>|
      \ nnoremap ,rr :FloatermNew --autoclose=0 python %<space>|
      \ call <SID>IndentSize(4)
    autocmd FileType perl nmap <buffer> ,l <Plug>SlimeLineSend
  augroup END

]]
