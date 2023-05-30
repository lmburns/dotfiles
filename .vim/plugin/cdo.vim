function! s:_cdo(args, type)
  let no_confirmation_needed = matchstr(a:args,'^/c') == ""
  let command = substitute(a:args, '^/c', '', '')

  exe a:type.'rewind'
  let error_count = a:type == 'c' ? len(getqflist()) : len(getloclist(0))
  let i = 0
  while i < error_count
    let i = i + 1
    exe a:type.a:type." ".i
    let confirm_msg = "Change this line? - ".getline(".")
    if no_confirmation_needed || confirm(confirm_msg, "&yes\n&no") == 1
      exe command
    endif
  endwhile
endfunction

command! -nargs=1 -bar Cdo :call s:_cdo(<q-args>, 'c')
command! -nargs=1 -bar Ldo :call s:_cdo(<q-args>, 'l')
