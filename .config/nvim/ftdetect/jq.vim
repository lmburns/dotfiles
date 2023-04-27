function! s:DetectJQ()
  if did_filetype() && &filetype !=# 'conf'
    return
  endif
  " if getline(1) =~# '^#!.*\<jq\>'
  if getline(1) =~# '^#!\f\+\<jq\>'
    set filetype=jq
  endif
endfunction

au BufNewFile,BufRead,StdinReadPost *.jq,.jqrc*,jqrc set filetype=jq
au BufNewFile,BufRead,StdinReadPost * call s:DetectJQ()
