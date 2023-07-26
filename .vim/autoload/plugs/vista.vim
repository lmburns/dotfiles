func! plugs#vista#project() abort
  call vista#finder#fzf#ProjectRun('ctags')
endfu

func! plugs#vista#setup() abort
  " let g:vista_fzf_opt = ['--no-border']
  let g:vista_fzf_preview = ['down:50%']
  let g:vista_keep_fzf_colors = 0
  let g:vista_default_executive = 'coc'
  let g:vista_sidebar_position = 'vertical botright'
  let g:vista_echo_cursor_strategy = 'both'
  let g:vista#renderer#enable_icon = 1
  let g:vista#renderer#enable_kind = 1
  let g:vista_executive_for = {
      \  'vimwiki': "markdown",
      \  'pandoc': "markdown",
      \  'markdown': "toc",
      \ }

  nnoremap <C-M-"> <Cmd>Vista!!<CR>
  nnoremap <M-\>   <Cmd>Vista finder fzf:coc<CR>
  nnoremap <M-]>   <Cmd>Vista finder ctags<CR>
  nnoremap <M-S-}> <Cmd>call plugs#vista#project()<CR>
  nnoremap <Leader>jp <Cmd>call plugs#vista#project()<CR>

  " nmap <C-S-\> :CocCommand fzf-preview.VistaCtags<CR>
  " nmap <A-]> :CocCommand fzf-preview.VistaBufferCtags<CR>
  " nmap <A-]> :<C-u>CocCommand fzf-preview.VistaBufferCtags --add-fzf-arg=--preview-window=':nohidden,bottom:50%'<CR>

  nmap <silent> <Leader>T  <Cmd>Tags<CR>
  nmap <silent> <M-t>      <Cmd>BTags<CR>
  nmap <silent> <LocalLeader>t  <Cmd>CocCommand fzf-preview.BufferTags<CR>

  augroup lmb__VistaNearest
    autocmd!
    autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
  augroup END
endfu
