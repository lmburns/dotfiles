fun! s:fugitive_detect() abort
  if !exists('b:git_dir')
    call FugitiveDetect()
  end
endfun

fun! s:index() abort
  let bufname = bufname()
  if winnr('$') == 1 && bufname == ''
    Git
  else
    tab Git
  endif
  if bufname == ''
    sil! noa bw #
  endif
endfun

" placeholder for Git difftool --name-only
fun! s:diff_hist() abort
  let l:info = getqflist({'idx': 0, 'context': 0})
  let [l:idx, l:ctx] = [l:info.idx, l:info.context]
  if !empty(l:idx) && !empty(l:ctx) && l:ctx.items == v:t_dict
    let l:diff = get(l:ctx.items[l:idx], 'diff', {})
    if len(l:diff) == 1
      exec "abo vert diffs ".l:diff[0].filename
      winc p
    endif
  endif
endfun

fun! s:fugitive_buf_mappings() abort
endfun

fun! plugs#fugitive#mappings()
  nnoremap <Leader>gu <Cmd>G<CR>3j
  nnoremap <Leader>gq <Cmd>G<CR>:q<CR>
  nnoremap <Leader>gw <Cmd>Gwrite<CR>
  nnoremap <Leader>gr <Cmd>Gread<CR>
  " nnoremap <Leader>gh <Cmd>diffget //2<CR>
  " nnoremap <Leader>gl <Cmd>diffget //3<CR>
  nnoremap <Leader>gp <Cmd>Git push<CR>
  nmap <Leader>d <Cmd>Gdiff<CR>

  nnoremap <LocalLeader>gg <Cmd>call s:index()<CR>
  nnoremap <LocalLeader>ge <Cmd>Gedit<CR>
  nnoremap <LocalLeader>gR <Cmd>Gread<CR>
  nnoremap <LocalLeader>gB <Cmd>Git blame -w<Bar>winc p<CR>

  " Fugitive: Gwrite
  nnoremap <LocalLeader>gw <Cmd>call usr#utils#follow_symlink()<CR><Cmd>Gwrite<CR>
  " Fugitive: Gwrite
  nnoremap <LocalLeader>gW <Cmd>call usr#utils#follow_symlink('Gwrite')
  " Fugitive: Gread
  nnoremap <LocalLeader>gr <Cmd>call usr#utils#follow_symlink()<CR><Cmd>keepalt Gread<Bar>up!<CR>

  " Fugitive: fetch all
  nnoremap <LocalLeader>gf <Cmd>Git fetch --all<CR>
  " Fugitive: fetch origin
  nnoremap <LocalLeader>gF <Cmd>Git fetch origin<CR>
  " Fugitive: pull
  nnoremap <LocalLeader>gp <Cmd>Git pull<CR>
  " Fugitive: buffer split
  nnoremap <LocalLeader>gs <Cmd>Gsplit<CR>
  " Fugitive: difftool name-only
  nnoremap <LocalLeader>gn <Cmd>Git! difftool --name-only<Bar>copen<CR>
  " Fugitive: commit
  nnoremap <LocalLeader>gc :Git commit<Space>
  " Fugitive: commit (amend)
  nnoremap <LocalLeader>ga :Git commit --amend<Space>
  " Fugitive: tab Gdiffsplit
  nnoremap <LocalLeader>gT :tab Gdiffsplit<Space>

  " nnoremap <leader>gw <Cmd>execute 'FollowSymlink' <bar> Gwrite<CR>
  " nnoremap <leader>gr <Cmd>execute 'FollowSymlink' <bar> keepalt Gread <bar> w!<CR>

  " Fugitive: relative log
  nnoremap <expr> <LocalLeader>gz
        \ '@_<Cmd>G log --pretty="%h%d %s  %aL (%cr)" --date=relative'.(v:count ? '' : ' --follow -- %').'<CR>'
  " Fugitive: log stat last
  nnoremap <LocalLeader>gZ :G log --stat --cumulative -n1<CR>
  nnoremap <silent> <leader>gd <Cmd>Gdiffsplit<CR>
  nnoremap <silent> <leader>gD <Cmd>Gdiffsplit HEAD<CR>
  nnoremap <silent> qd <Cmd>call fugitive#DiffClose()<CR>
endfun

fun! plugs#fugitive#autocmds()
  aug lmb__Fugitive
    au!
    au User FugitiveIndex,FugitiveCommit call s:fugitive_buf_mappings()
    au BufReadPost fugitive://* set bufhidden=delete
  aug END
endfun

fun! plugs#fugitive#setup()
  let g:nremap = {'d?': 's?', 'dv': 'sv', 'dp': 'sp', 'ds': 'sh', 'dh': 'sh', 'dq': 'qd',
        \ 'd2o': 's2o', 'd3o': 's3o', 'dd': 'ss', 's': 'S', 'u': '<C-u>', 'O': 'T',
        \ '[m': '[f', ']m': ']f'}
  let g:xremap = {'s': 'S', 'u': '<C-u>'}

  call plugs#fugitive#mappings()
  call plugs#fugitive#autocmds()
endfun
