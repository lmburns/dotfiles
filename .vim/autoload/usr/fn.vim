fun! usr#fn#trim_whitespace(...)
  " call usr#shared#utils#preserve('%s/\\\@<!\s\+$//e')

  " Delete trailing blank lines at end of file
  " call usr#shared#utils#preserve('0;/^\%(\n*.\)\@!/,$d')

  " End of lines
  call usr#shared#utils#preserve('%s/\s\+$//ge')
  " Delete trailing blank lines
  call usr#shared#utils#preserve('%s#\($\n\s*\)\+\%$##e')
endfun

fun! usr#fn#profile(...)
  if a:0 && a:1 != 1
    let g:profile_file = a:1
  else
    let g:profile_file = '/tmp/vim.'..getpid()..'.'..reltimestr(reltime())[-4:]..'profile.txt'
    echom "Profiling into" g:profile_file
    if a:0 < 2 || a:2
      let @* = g:profile_file
    endif
  endif
  exec 'profile start '.g:profile_file
  profile! file **
  profile  func *
endfun

fun! usr#fn#range_search(direction)
  call inputsave()
  let g:srchstr = input(a:direction)
  call inputrestore()
  if strlen(g:srchstr) > 0
    let g:srchstr = g:srchstr.
          \ '\%>'..(line("'<")-1)..'l'.
          \ '\%<'..(line("'>")+1)..'l'
  else
    let g:srchstr = ''
  endif
endfu

fun! usr#fn#synstack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfun

":verbose hi <name>
" SyntaxQuery: Display the syntax stack at current cursor position
fun! usr#fn#syntax_query() abort
  for id in synstack(line("."), col("."))
    execute 'hi' synIDattr(id, "name")
  endfor
endfun

fun! usr#fn#ToggleLastChar(pat)
  let view = winsaveview()
  try
    keepj keepp exe 's/\([^'.escape(a:pat,'/').']\)$\|^$/\1'.escape(a:pat,'/').'/'
  catch /^Vim\%((\a\+)\)\=:E486: Pattern not found/
    keepj keepp exe 's/'.escape(a:pat, '/').'$//'
  finally
    call winrestview(view)
  endtry
endfun
