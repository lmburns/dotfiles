fun! usr#shared#utils#preserve(command)
  let l:view = winsaveview()
  let l:last_search = getreg('/')
  let l:curline = getpos('.')[1]

  exec 'keepj keepp keepm ' . a:command

  let l:lastline = line("$")
  if l:curline > l:lastline
    let l:curline = l:lastline
  endif

  call cursor([l:curline, l:view.col])
  call winrestview(l:view)
  call setreg('/', l:last_search)
endfun

" Run the normal mode {command} from line {start} to {end}, opening any folds.
fun! usr#shared#utils#mark_visual(command, start, end) abort
  if a:start != line('.') | exec a:start | endif

  sil! exec printf('%d,%dfoldopen', a:start, a:end)

  if a:end > a:start
    exec 'normal!' a:command . (a:end - a:start) . 'jg_'
  else
    exec 'normal!' a:command . 'g_'
  endif
endfun

fun! usr#shared#utils#resolve_symlink(...)
  if exists('w:no_resolve_symlink') && w:no_resolve_symlink
    return
  endif
  if &ft == 'help'
    return
  endif
  let fname = a:0 ? a:1 : expand('%')
  if fname =~ '^\w\+:/'
    " Not for 'fugitive://', 'man://', etc
    return
  endif
  let fname = simplify(fname)

  let resolvedfile = resolve(fname)
  if resolvedfile == fname
    return
  endif
  let resolvedfile = fnameescape(resolvedfile)
  let sshm = &shm
  redraw         " Redraw to avoid hit-enter prompt
  exec 'file ' . resolvedfile
  let &shm=sshm

  unlet! b:git_dir
  call fugitive#detect(resolvedfile)

  if &modifiable
    redraw
    echomsg 'Resolved symlink: =>' resolvedfile
  endif
endfun

" Execute the normal mode {motion} and return the text that it marks. For this
" to work, the {motion} must include a visual mode key (`V`, `v`, or `gv`).
"
" Both the 'z' register and the original cursor position will be restored
" after the text is yanked.
fun! usr#shared#utils#get_motion(motion) abort
  let l:cursor = getpos('.')
  let l:reg = getreg('z')
  let l:type = getregtype('z')

  exec 'normal!' a:motion . '"zy'

  let l:text = @z

  call setreg('z', l:reg, l:type)
  call setpos('.', l:cursor)

  return l:text
endfun

" utils#get_var: gets the value of {var}, checking for a buffer override then
"   a global value. That is, {var} will be pulled from |b:|, then |g:|.
"   A [default] value may be provided.
fun! usr#shared#utils#get_var(var, ...) abort
  return get(b:, a:var, get(g:, a:var, get(a:000, 0, '')))
endfun

" utils#get: get a copy of an item or return a default value
"   @usage {list} {index} [default]
"     Get a copy of the item at {index} from |List| {list},
"     returning [default] if it is not available.
"   @usage {dict} {key} [default]
"     Get an copy of the item with key {key} from |Dictionary| {dict},
"     returning [default] if it is not available.
"   @usage {func} {what}
"     Get an item {what} from Funcref {func}.
fun! usr#shared#utils#get(expr, index, ...) abort
  if type(a:expr) == v:t_func
    return get(a:expr, a:index)
  elseif a:0
    return deepcopy(get(a:expr, a:index, a:1))
  else
    return deepcopy(get(a:expr, a:index))
  endif
endfun
