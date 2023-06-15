let s:bufnr = { bufnr -> bufnr == 0 ? bufnr() : bufnr }

let s:V = vital#vimrc#new()

let s:List = s:V.import('Data.List')
let s:Msg = s:V.import('Vim.Message')

" Check if {bufnr} is valid
" @param bufnr number buffer number
" @return boolean
func! api#buf#is_valid(bufnr) abort
  return buflisted(a:bufnr)
      \  && ("" ==# getbufvar(a:bufnr, "&buftype") || "help" ==# getbufvar(a:bufnr, "&buftype"))
      \  && a:bufnr != bufnr("%")
      \  && -1 == index(tabpagebuflist(), a:bufnr)
      \  && !(getbufvar(a:bufnr, "&modified") && getbufvar(a:bufnr, "&readonly"))
endf

" Like `bufwinid()` except it works across tabpages
" @param bufnr bufnr
" @return winid?
func! api#buf#buftabwinid(bufnr) abort
  let bufnr = s:bufnr(a:bufnr)
  for win in api#win#list_wins()
    if api#win#get_buf(win) == bufnr
      return win
    endif
  endfor

  return 0
endf

" Determine whether a buffer is hidden
" @param bufnr bufnr
" @return boolean
func! api#buf#is_hidden(bufnr) abort
  for tabnr in api#tab#list_tabpages()
    for winid in api#tab#list_wins(tabnr)
      let winbuf = api#win#get_buf(winid)
      if api#win#is_valid(winid) && winbuf == a:bufnr
        return v:false
      endif
    endfor
  endfor

  return v:true
endf

" Get the tabnr for {bufnr}
" @param bufnr number
" @return tabnr|0
func! api#buf#get_tab(bufnr) abort
  for tabnr in range(tabpagenr("$"))
    if index(tabpagebuflist(tabnr + 1), a:bufnr) != -1
      return tabnr + 1
    endif
  endfor

  return 0
endf

" Get the number of listed buffers
" @return number
func! api#buf#get_count(bufnr) abort
  return len(getbufinfo(#{buflisted: 1}))
endf

" Check whether the current buffer is modified
" @param bufnr? integer
" @return boolean
func! api#buf#is_modified(bufnr) abort
  return api#buf#get_option(a:bufnr, '&modified')
endf

" Determine whether the buffer is empty
" @param bufnr? integer
" @return boolean
func! api#buf#is_empty(bufnr) abort
  let bufnr = s:bufnr(a:bufnr)
  if bufnr == bufnr('%')
    return (line('$') == 1 && empty(getline(1)))
  endif

  let lines = api#buf#get_lines(bufnr, 1, '$')
  return (len(lines) == 1 && empty(lines[0]))
endf

" Get buffer info of buffers that match given options. Minus extra junk
" @return table[]
func! api#buf#bufinfo_short()
  let info = {}
  for bufnr in api#buf#list_bufs()
    let info[bufnr] = map(getbufinfo(bufnr),
        \ '#{
        \    bufnr: v:val.bufnr,
        \    name: v:val.name,
        \    changed: v:val.changed,
        \    hidden: v:val.hidden,
        \    lastused: v:val.lastused,
        \    linecount: v:val.linecount,
        \    listed: v:val.listed,
        \    lnum: v:val.lnum,
        \    loaded: v:val.loaded,
        \    windows: v:val.windows,
        \ }')
  endfor

  return info
endf

"  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

" Simulate `nvim_buf_get_number()`
" Gets the number in the order of valid buffers
" @param bufnr number
" @return number
func! api#buf#get_number(bufnr) abort
  return index(api#buf#list_bufs(), s:bufnr(a:bufnr)) + 1
endf

" Simulate `nvim_get_current_buf()`
" Gets the current buffer.
" @return bufnr
func! api#buf#get_current() abort
  return bufnr()
endf

" Simulate `nvim_set_current_buf()`
" Sets the current buffer.
" @param bufnr
func! api#buf#set_current(bufnr) abort
endf

" Simulate `nvim_list_bufs()`
" Gets the current list of buffer handles
" @return List<bufnr>
func! api#buf#list_bufs() abort
  return map(getbufinfo(), 'v:val.bufnr')
endf

" Simulate `nvim_get_current_line()`
" Gets the current line.
" @return string
func! api#buf#get_current_line() abort
  return getline(line('.'))
endf

" Simulate `nvim_set_current_line()`
" Sets the current line.
" @param text string
" @return boolean
func! api#buf#set_current_line(text) abort
  return setline(line('.'), a:text)
endf

" Simulate `nvim_del_current_line()`
" Deletes the current line.
" @return boolean
func! api#buf#del_current_line() abort
  return deletebufline(bufnr(), line('.'))
endf

" Simulate `nvim_buf_get_text()`
" Gets a range from the buffer.
" @param bufnr number
" @param start_row number
" @param start_col number
" @param end_row number
" @param end_col number
" @return List<string>
func! api#buf#get_text(bufnr, start_row, start_col, end_row, end_col) abort
  let lines = getbufline(s:bufnr(a:bufnr), a:start_row, a:end_row)
  if lines[0] != ''
    let lines[0] = lines[0][a:start_col:]
  endif
  if lines[-1] != ''
    let lines[-1] = lines[-1][:a:end_col]
  endif
  return lines
endf

" Simulate `nvim_buf_set_text()`
" Sets (replaces) a range in the buffer
" @param bufnr number
" @param start_row number
" @param start_col number
" @param end_row number
" @param end_col number
" @param repl string
func! api#buf#set_text(bufnr, start_row, start_col, end_row, end_col, repl) abort
  " TODO: finish using cols
  let bufnr = s:bufnr(a:bufnr)
  let idx = 0
  for line in range(a:start_row, a:end_row)
    call setbufline(bufnr, line, a:repl[idx])
    let idx = idx + 1
  endfor
endf

" Simulate `nvim_buf_get_lines()`
" Gets a line-range from the buffer.
" @param bufnr number
" @param start number
" @param endl number
" @return List<string>
func! api#buf#get_lines(bufnr, start, endl) abort
  return getbufline(s:bufnr(a:bufnr), a:start, a:endl)
endf

" Simulate `nvim_buf_set_lines()`
" Sets (replaces) a line-range in the buffer.
" @param bufnr number
" @param start number
" @param endl number
" @param repl text
func! api#buf#set_lines(bufnr, start, endl, repl) abort
  let bufnr = s:bufnr(a:bufnr)
  let idx = 0
  for line in range(a:start, a:endl)
    call setbufline(bufnr, line, a:repl[idx])
    let idx = idx + 1
  endfor
endf

" Simulate `nvim_buf_line_count()`
" Returns the number of lines in the given buffer.
" @param bufnr number
" @return number
func! api#buf#line_count(bufnr) abort
  " return len(api#buf#get_lines(a:bufnr, 1, '$'))
  " return map(getbufinfo(s:bufnr(a:bufnr)), 'v:val.linecount')

  let bufnr = s:bufnr(a:bufnr)
  if bufnr == bufnr('%')
    return line('$')
  endif
  if exists('*getbufinfo')
    let count = map(getbufinfo(bufnr), 'v:val.linecount')
    if empty(count)
      return 0
    endif
    return count[0]
  endif
  return len(api#buf#get_lines(bufnr, 1, '$'))
endf

" Simulate `nvim_buf_call()`
" Call a function with buffer as temporary current buffer
" @param bufnr number
" @param fun fun()
func! api#buf#call(bufnr, fun) abort
endf

" Simulate `nvim_buf_delete()`
" Deletes the buffer. See |:bwipeout|
" @param bufnr number
func! api#buf#delete(bufnr) abort
  bwipeout a:bufnr
endf

" Simulate `nvim_buf_is_loaded()`
" Checks if a buffer is valid and loaded. See |api-buffer| for more info about unloaded buffers.
" @param bufnr number
" @return boolean
func! api#buf#is_loaded(bufnr) abort
  let bufnr = s:bufnr(a:bufnr)
  return api#buf#is_valid(bufnr) && api#buf#get_var(bufnr, '&bufloaded')
endf

" Simulate `nvim_buf_is_loaded()`
" Checks if a buffer is valid.
" @param bufnr number
func! api#buf#is_valid(bufnr) abort
  return index(api#buf#list_bufs(), a:bufnr) >= 0
endf

" Simulate `nvim_buf_get_keymap()`
" Gets a list of buffer-local |mapping| definitions.
" @param bufnr number
" @param mode string
func! api#buf#get_keymap(bufnr, mode) abort
endf

" Simulate `nvim_buf_del_keymap()`
" Unmaps a buffer-local |mapping| for the given mode.
" @param bufnr number
" @param mode string
" @param lhs string
func! api#buf#del_keymap(bufnr, mode, lhs) abort
endf

" Simulate `nvim_buf_get_mark()`
" Returns a tuple (row,col) representing the position of the named mark. See |mark-motions|.
" @param bufnr number
" @param name string
func! api#buf#get_mark(bufnr, name) abort
endf

" Simulate `nvim_buf_set_mark()`
" Sets a named mark in the given buffer, all marks are allowed
" file/uppercase, visual, last change, etc. See |mark-motions|.
" @param bufnr number
" @param name string
" @param line number
" @param col number
func! api#buf#set_mark(bufnr, name, line, col) abort
endf

" Simulate `nvim_buf_del_mark()`
" Deletes a named mark in the buffer. See |mark-motions|.
" @param bufnr number
" @param name string
func! api#buf#del_mark(bufnr, name) abort
endf

" Simulate `nvim_buf_get_var()`
" Gets a buffer-scoped (b:) variable.
" @param bufnr number
" @param name string
" @return any
func! api#buf#get_var(bufnr, name) abort
  return getbufvar(s:bufnr(a:bufnr), a:name)
endf

" Simulate `nvim_buf_set_var()`
" Sets a buffer-scoped (b:) variable
" @param bufnr number
" @param name string
" @param value any
" @return any
func! api#buf#set_var(bufnr, name, value) abort
  return setbufvar(s:bufnr(a:bufnr), a:name, a:value)
endf

" Simulate `nvim_buf_del_var()`
" Removes a buffer-scoped (b:) variable
" @param bufnr number
" @param name string
" @return any
func! api#buf#del_var(bufnr, name) abort
  " TODO: work with any buffer
  exec 'unlet b:'..a:name
  " return setbufvar(s:bufnr(a:bufnr), a:name, v:null)
endf

" Simulate `nvim_buf_get_option()`
" Gets a buffer option value
" @param bufnr number
" @param opt string
" @return any
func! api#buf#get_option(bufnr, opt) abort
  return api#buf#get_var(a:bufnr, '&'..a:opt)
endf

" Simulate `nvim_buf_set_option()`
" Sets a buffer option value.
" Passing `nil` as value deletes the option (only works if there's a global fallback)
" @param bufnr number
" @param opt string
" @param value any
func! api#buf#set_option(bufnr, opt, value) abort
  return api#buf#set_var(a:bufnr, '&'..a:opt, a:value)
endf

" Simulate `nvim_buf_get_name()`
" Gets the full file name for the buffer
" @param bufnr number
" @return string
func! api#buf#get_name(bufnr) abort
  return fnamemodify(bufname(s:bufnr(a:bufnr)), ':p')
endf

" Simulate `nvim_buf_set_name()`
" Sets the full file name for a buffer
" @param bufnr number
" @param name string
func! api#buf#set_name(bufnr) abort
endf

"  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

" Check if buffer name is a terminal
" @param ...[0] bufname string
" @return boolean
func! api#buf#bufname_is_term(...) abort
  let l:bufname = a:0 ? a:1 : bufname()
  if l:bufname =~# 'term://.*'
    return v:true
  endif
  return v:false
endf

" Determine whether a buffer should be excluded
" @param bufnr? number buffer number
" @param winid? number window id
" @param exft? string[] filetypes to exclude
" @param inbt? string[] buffer types to include
" @return boolean
func! api#buf#should_exclude(...) abort
  let l:bufnr = get(a:, 1, bufnr())
  let l:bufpath = expand('%:p')
  let l:bufname = bufname(l:bufnr)
  let l:winid = get(a:, 2, bufwinid(l:bufnr))
  let l:exclude_ft = get(a:, 3, g:Rc.blacklist.ft)
  let l:include_bt = get(a:, 4, ['', 'acwrite'])

  if l:bufpath == ''
      \ || !filereadable(l:bufpath)
      \ || l:bufname ==# '[No name]'
      \ || s:List.any({val -> l:bufname =~# val}, g:Rc.blacklist.bufname)
      \ || index(l:exclude_ft, &ft) >= 0
      \ || !buflisted(l:bufnr)
      \ || win_gettype() ==# 'popup'
    return v:true
  endif
  return v:false
endfun

"  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func! api#buf#goto_alt() abort
  " change to alternate buffer if it is not the current buffer (yes, that can happen)
  if buflisted(bufnr("#")) && bufnr("#") != bufnr("%")
    buffer #
    return 1
  endif

  " change to newest valid buffer
  let lastbnr = bufnr('$')
  if api#buf#is_valid(lastbnr)
    exe 'buffer '.lastbnr
    return 1
  endif

  " change to any valid buffer
  let validbufs = s:buf_find_valid_next_bufs()
  if len(validbufs) > 0
    exe 'buffer '.validbufs[0]
    return 1
  endif

  return 0
endf

"  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

func! s:buf_find_valid_next_bufs() abort
  let validbufs = filter(range(1, bufnr('$')), 'api#buf#is_valid(v:val)')
  call sort(validbufs, '<SID>compare_bufs')
  return validbufs
endf

func! s:compare_numbers(n1, n2) abort
  return a:n1 == a:n2 ? 0 : a:n1 > a:n2 ? 1 : -1
endfunc

func! s:compare_bufs(b1, b2) abort
  let b1_visible = index(tabpagebuflist(), a:b1) >= 0
  let b2_visible = index(tabpagebuflist(), a:b2) >= 0
  " - sort by buffer number (descending)
  " - prefer loaded, NON-visible buffers
  if bufloaded(a:b1)
    if bufloaded(a:b2)
      if b1_visible == b2_visible
        return s:compare_numbers(a:b1, a:b2)
      endif
      return s:compare_numbers(b2_visible, b1_visible)
    endif
    return 1
  endif
  return !bufloaded(a:b2) ? s:compare_numbers(a:b1, a:b2) : 1
endf

" Gets the first empty, unchanged buffer not in the current tabpage.
func! s:buf_find_unused() abort
  for i in range(1, bufnr('$'))
    if bufexists(i)
        \&& -1 == index(tabpagebuflist(), i)
        \&& buflisted(i)
        \&& bufname(i) ==# ''
        \&& getbufvar(i, '&buftype') ==# ''
      return i
    endif
  endfor
  return 0
endf

" Switches to a new (empty, unchanged) buffer or creates a new one.
func! s:buf_new() abort
  let newbuf = s:buf_find_unused()
  if newbuf == 0
  enew
else
  exe 'buffer' newbuf
endif
endf
