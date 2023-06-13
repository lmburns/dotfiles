" Copied/Adapted from vim-rails
exe 'cmap <buffer><script><expr> <Plug><cfile> <SID>Includeexpr()'

nmap <buffer><silent> gf         :find    <Plug><cfile><CR>
nmap <buffer><silent> <C-W>f     :sfind   <Plug><cfile><CR>
nmap <buffer><silent> <C-W><C-F> :sfind   <Plug><cfile><CR>
nmap <buffer><silent> <C-W>gf    :tabfind <Plug><cfile><CR>
cmap <buffer>         <C-R><C-F> <Plug><cfile>

function! s:Includeexpr() abort
  let filename = ''

  try
    let saved_iskeyword = &iskeyword
    set iskeyword+=#

    let filename = expand('<cword>')
  finally
    let &iskeyword = saved_iskeyword
  endtry

  if stridx(filename, '#') >= 0
    let parts = split(filename, '#')
    let path = 'autoload/' .. join(parts[0:-2], '/') .. '.vim'
    let resolved_path = globpath(&runtimepath, path)

    if resolved_path != ''
      call rustbucket#util#SetFileOpenCallback(resolved_path, '^\s*fun.*\<\zs' .. filename .. '(')
      return resolved_path
    endif
  elseif filename =~ '^\s*runtime'
    for dir in split(&rtp, ',')
      let fname = dir.'/'.a:fname

      if filereadable(fname)
        return fname
      endif
    endfor
  endif

  return expand('<cfile>')
endfunction

command! -buffer Lookup call lookup#lookup()
nnoremap <buffer> gd :call lookup#lookup()<cr>

setlocal tagfunc=VimTagfunc

function! VimTagfunc(pattern, flags, info) abort
  if stridx(a:flags, 'c') >= 0 && stridx(a:flags, 'i') < 0
    return taglist(s:VimCursorTag(), get(a:info, 'buf_ffname', ''))
  else
    return v:null
  endif
endfunction

function! s:VimCursorTag() abort
  let pattern = '\%(\k\+#\)*\%([bgstw]:\|<SID>\)\=\k\+'

  if !search(pattern, 'Wbc', line('.'))
    return ''
  endif
  let start_col = col('.')

  if !search(pattern, 'We', line('.'))
    return ''
  endif
  let end_col = col('.')

  let identifier = sj#GetCols(start_col, end_col)
  let identifier = substitute(identifier, '^<SID>', 's:', '')
  return identifier
endfunction
