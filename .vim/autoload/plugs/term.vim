func! plugs#term#floaterm() abort
  nnoremap <silent> <Leader>fll <Cmd>Floaterms<CR>
  nnoremap <silent> <Leader>flt <Cmd>FloatermToggle<CR>
  nnoremap <Leader>so  :FloatermNew --autoclose=0 so<space>

  let g:fzf_floaterm_newentries = {
        \ '+lazygit' : {
        \    'title': 'lazygit',
        \    'height': 0.9,
        \    'width': 0.9,
        \    'cmd' : 'lazygit'
        \ },
        \ '+gitui' : {
        \ '  title': 'gitui',
        \ '  height': 0.9,
        \ '  width': 0.9,
        \ '  cmd' : 'gitui'
        \ },
        \ '+taskwarrior-tui' : {
        \   'title': 'taskwarrior-tui',
        \   'height': 0.99,
        \   'width': 0.99,
        \   'cmd' : 'taskwarrior-tui'
        \ },
        \ '+flf' : {
        \   'title': 'full screen lf',
        \   'height': 0.9,
        \   'width': 0.9,
        \   'cmd' : 'lf'
        \ },
        \ '+slf' : {
        \   'title': 'split screen lf',
        \   'wintype': 'split',
        \   'height': 0.5,
        \   'cmd' : 'lf'
        \ },
        \ '+xplr' : {
        \   'title': 'xplr',
        \   'cmd' : 'xplr'
        \ },
        \ '+gpg-tui' : {
        \   'title': 'gpg-tui',
        \   'height': 0.9,
        \   'width': 0.9,
        \   'cmd': 'gpg-tui'
        \ },
        \ '+tokei' : {
        \   'title': 'tokei',
        \   'height': 0.9,
        \   'width': 0.9,
        \   'cmd': 'tokei'
        \ },
        \ '+dust' : {
        \   'title': 'dust',
        \   'height': 0.9,
        \   'width': 0.9,
        \   'cmd': 'dust'
        \ },
        \}

  let g:floaterm_shell   = 'zsh'
  let g:floaterm_wintype = 'float'
  let g:floaterm_opener  = 'edit'
  let g:floaterm_height  = 0.8
  let g:floaterm_width   = 0.8
endfu

func! plugs#term#neoterm() abort
  let g:neoterm_default_mod='belowright' " open terminal in bottom split
  let g:neoterm_size=14                  " terminal split size
  let g:neoterm_autoscroll=1             " scroll to the bottom
  " nnoremap <Leader>rf :T ptipython<CR>
  " some modules do not work in ptpython
  nnoremap <Leader>rr <Cmd>Tclear<CR>
  nnoremap <Leader>rt <Cmd>Ttoggle<CR>
  nnoremap <Leader>ro <Cmd>Ttoggle<CR>
endfu
