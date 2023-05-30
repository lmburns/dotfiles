fun! s:fugitive_detect() abort
  if !exists('b:git_dir')
    call FugitiveDetect()
  end
endfun

fun s:index() abort
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
      exec "abo vert diffs "..l:diff[0].filename
      winc p
    endif
  endif
endfun

fun! s:fugitive_buf_mappings() abort
endfun

fun! plugs#fugitive#mappings()
  nnoremap <Leader>gu :G<CR>3j
  nnoremap <Leader>gq :G<CR>:q<CR>
  nnoremap <Leader>gw :Gwrite<CR>
  nnoremap <Leader>gr :Gread<CR>
  nnoremap <Leader>gh :diffget //2<CR>
  nnoremap <Leader>gl :diffget //3<CR>
  nnoremap <Leader>gp :Git push<CR>
  nmap <Leader>d :Gdiff<CR>

  nnoremap <LocalLeader>gg :call s:index()<CR>
  nnoremap <LocalLeader>ge :Gedit<CR>
  nnoremap <LocalLeader>gR :Gread<CR>
  nnoremap <LocalLeader>gB :Git blame -w<Bar>winc p<CR>

  " Fugitive: Gwrite
  " nnoremap <LocalLeader>gw :follow_symlink()<CR><Cmd>Gwrite<CR>
  " Fugitive: Gwrite
  " nnoremap <LocalLeader>gW :follow_symlink('Gwrite')
  " Fugitive: Gread
  " nnoremap <LocalLeader>gr :follow_symlink()<CR><Cmd>keepalt Gread<Bar>up!<CR>

  " Fugitive: fetch all
  nnoremap <LocalLeader>gf :Git fetch --all<CR>
  " Fugitive: fetch origin
  nnoremap <LocalLeader>gF :Git fetch origin<CR>
  " Fugitive: pull
  nnoremap <LocalLeader>gp :Git pull<CR>
  " Fugitive: buffer split
  nnoremap <LocalLeader>gs :Gsplit<CR>
  " Fugitive: difftool name-only
  nnoremap <LocalLeader>gn :Git! difftool --name-only<Bar>copen<CR>
endfun

fun! plugs#fugitive#autocmds()
    aug lmb__Fugitive
        au!
        au User FugitiveIndex,FugitiveCommit call s:fugitive_buf_mappings()
        au BufReadPost fugitive://* set bufhidden=delete
    aug END
endfun

fun! plugs#fugitive#setup()
    " packadd vim-rhubarb
    call plugs#fugitive#mappings()
    call plugs#fugitive#autocmds()
endfun
