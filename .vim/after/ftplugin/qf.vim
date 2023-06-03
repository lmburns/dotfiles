if !get(s:, 'ready')
  fun! s:AdjustWindowHeight(minheight, maxheight)
    exe max([a:minheight, min([line('$') + 1, a:maxheight])]) . 'wincmd _'
  endf

  fun! s:jump_stack(reverse, use_loclist) abort
    try
      if a:use_loclist
        if a:reverse
          lolder
        else
          lnewer
        endif
      else
        if a:reverse
          colder
        else
          cnewer
        endif
      endif
    catch /^Vim\%((\a\+)\)\=:E38[01]:/
    endtry
  endf

  let s:ready = v:true
endif

" fix last window is floating with hl and blend
setl so=2
setl nospell
setl nolist

augroup QuickfixAutocmds
  autocmd!
  autocmd BufReadPost quickfix call <SID>AdjustWindowHeight(2, 30)
augroup END

noremap <buffer> qa <Cmd>q<CR><Cmd>qa<CR>

if len(getloclist(0)) > 0
  nnoremap <buffer> H <Cmd>call <SID>jump_stack(v:true, v:true)<CR>
  nnoremap <buffer> L <Cmd>call <SID>jump_stack(v:false, v:true)<CR>
  nnoremap <buffer> { <Cmd>call <SID>jump_stack(v:true, v:true)<CR>
  nnoremap <buffer> } <Cmd>call <SID>jump_stack(v:false, v:true)<CR>
else
  nnoremap <buffer> H <Cmd>call <SID>jump_stack(v:true, v:false)<CR>
  nnoremap <buffer> L <Cmd>call <SID>jump_stack(v:false, v:false)<CR>
  nnoremap <buffer> { <Cmd>call <SID>jump_stack(v:true, v:false)<CR>
  nnoremap <buffer> } <Cmd>call <SID>jump_stack(v:false, v:false)<CR>
endif
