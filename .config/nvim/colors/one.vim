if !(exists('g:colors_name') && g:colors_name ==# 'one')
  highlight clear
  if exists('syntax_on')
    syntax reset
  endif
endif

let g:colors_name = 'one'
