setlocal comments=:#
setlocal commentstring=#\ %s

nnoremap <silent><buffer> K :call tmux#man()<CR>
nnoremap <silent> <Plug>TmuxExec :<C-U>set opfunc=tmux#filterop<CR>g@
xnoremap <silent> <Plug>TmuxExec :<C-U>call tmux#filterop(visualmode())<CR>
nmap <buffer> g! <Plug>TmuxExec
nmap <buffer> g!! <Plug>TmuxExec_
xmap <buffer> g! <Plug>TmuxExec
