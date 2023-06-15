let s:winnr = { winnr -> winnr == 0 ? winnr() : winnr }
let s:winid = { winid -> winid == 0 ? win_getid() : winid }

" Determine if the window is the only one open
" @param winid 0|number
" @return boolean
func! api#win#is_last(winid) abort
  let winid = s:winid(a:winid)
  let n = 0
  for tab in api#tab#list_tabpages()
    for win in api#tab#list_wins(tab)
      if winid == win
        let n = n + 1
      endif
      if n > 1
        return v:false
      endif
    endfor
  endfor
  return v:true
endf

" Determine whether the window is floating
" @param winid? number
" @return boolean
func! api#win#is_float(winid) abort
  return win_gettype(api#win#get_number(a:winid)) == 'popup'
endf

" Find a window that is not floating
" @param bufnr number
" @return winid number
func! api#win#except_float(bufnr) abort
  let winid = bufwinid(a:bufnr)
  if api#win#is_float(winid)
    let f_winid = winid
    let winid = 0
    for wid in api#win#list_wins()
      if f_winid != wid && api#win#get_buf(wid) == bufnr
        let winid = wid
        break
      endif
    endfor
  endif
  return winid
endf

" Get windows of a given type
" @param wintype string
" @return number[]?
func! api#win#of_type(wintype) abort
  return filter(api#win#list_wins(), 'win_gettype(v:val) == a:wintype')
endf

" Return a table of window ID's for quickfix windows
" "@return number?
func! api#win#type_qf(wintype) abort
  return api#win#of_type('quickfix')[0]
endf

" Check if the buffer that contains the window is modified
" @param winid winid
" @return boolean
func! api#win#is_modified(winid) abort
  return api#win#get_buf_option(a:winid, "modified")
endf

" Get a buffer option from a window
" @param winid winid
" @param opt string option to get
" @return table|string|number|boolean
func! api#win#get_buf_option(winid, opt) abort
  let bufnr = api#win#get_buf(a:winid)
  return api#buf#get_option(bufnr, a:opt)
endf

" Get a buffer variable from a window
" @param winid winid
" @param var string variable to get
" @return any
func! api#win#get_buf_var(winid, var) abort
  let bufnr = api#win#get_buf(a:winid)
  return api#buf#get_var(bufnr, a:var)
endf

" Close all floating windows
func! api#win#close_all_floating() abort
  for win in api#win#list_wins()
    if api#win#is_float(win)
      " TODO: finish
      " call api#win#close(win, false)
    endif
  endfor
endf

" Focus the floating window
func! api#win#focus_floating() abort
  if api#win#is_float(win_getid())
    wincmd p
    return
  endif
  for winnr in range(1, winnr("$"))
    let winid = win_getid(winnr)
    " let conf = api.nvim_win_get_config(winid)
    " if conf.focusable and conf.relative !=# ""
    call api#win#set_current(winid)
    return
    " endif
  endfor
endf

" Get wininfo
" @return table[]
func! api#win#wininfo_short()
  let info = {}
  for winid in api#win#list_wins()
    let info[winid] = map(getwininfo(winid),
        \ '#{
        \    winnr: v:val.winnr,
        \    winid: v:val.winid,
        \    bufnr: v:val.bufnr,
        \    tabnr: v:val.tabnr,
        \    height: v:val.height,
        \    width: v:val.width,
        \    textoff: v:val.textoff,
        \    botline: v:val.botline,
        \    topline: v:val.topline,
        \    wincol: v:val.wincol,
        \    winrow: v:val.winrow,
        \    winbar: v:val.winbar,
        \    terminal: v:val.terminal,
        \    quickfix: v:val.quickfix,
        \    loclist: v:val.loclist,
        \    last_cursor: v:val.variables.last_cursor,
        \ }')
  endfor

  return info
endf

"  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

" Simulate `nvim_win_get_number()`
" Gets the window number
" @param winid number
" @return number
func! api#win#get_number(winid) abort
  return win_id2win(s:winid(a:winid))
endf

" Simulate `nvim_get_current_win()`
" Gets the current window.
" @return
func! api#win#get_current() abort
  return win_getid()
endf

" Simulate `nvim_set_current_win()`
" Sets the current window.
" @param winid number
" @return boolean
func! api#win#set_current(winid) abort
  return win_gotoid(a:winid)
endf

" Simulate `nvim_list_wins()`
" Gets the current list of window handles.
" @return List<winid>
func! api#win#list_wins() abort
  " return map(range(1, winnr('$')), 'win_getid(v:val)')
  return map(getwininfo(), 'v:val.winid')
endf

" Simulate `nvim_win_call()`
" Calls a function with window as temporary current window.
" @param winid number
" @param func fun()
" @param silent boolean
" @return boolean
func! api#win#call(winid, func, silent) abort
  return win_execute(s:winid(a:winid), a:func, a:silent)
endf

" Simulate `nvim_win_close()`
" Closes the window (like |:close| with a |window-ID|).
" @param winid number
" @param force boolean
" @return boolean
func! api#win#close(winid, force) abort
endf

" Simulate `nvim_win_hide()`
" Closes the window and hide the buffer it contains (like |:hide| with a |window-ID|).
" @param winid number
" @return boolean
func! api#win#hide(winid, force) abort
endf

" Simulate `nvim_win_is_valid()`
" Checks if a window is valid
" @param winid number
" @return boolean
func! api#win#is_valid(winid) abort
  return index(api#win#list_wins(), a:winid) >= 0
endf

" Simulate `nvim_win_get_position()`
" Gets the window position in display cells
" @param winid number
func! api#win#get_position(winid) abort
  return win_screenpos(a:winid)
endf

" Simulate `nvim_win_get_buf()`
" Gets the current buffer in a window
" @param winid number
" @return [row, col]
func! api#win#get_buf(winid) abort
  return winbufnr(api#win#get_number(a:winid))
endf

" Simulate `nvim_win_set_buf()`
" Sets the current buffer in a window, without side effects
" @param winid number
" @param bufnr number
func! api#win#set_buf(winid, bufnr) abort
endf

" Simulate `nvim_win_get_tabpage()`
" Gets the window tabpage
" @param winid number
" @return tabpage number
func! api#win#get_tabpage(winid) abort
  return tabpagewinnr(api#win#get_number(a:winid))
endf

" Simulate `nvim_win_get_var()`
" Gets a window-scoped (w:) variable
" @param winid number
" @param name string
" @return any
func! api#win#get_var(winid, name) abort
  return getwinvar(s:winid(a:winid), a:name)
endf

" Simulate `nvim_win_set_var()`
" Sets a window-scoped (w:) variable
" @param winid number
" @param name string
" @param value any
" @return any
func! api#win#get_var(winid, name, value) abort
  return setwinvar(s:winid(a:winid), a:name, a:value)
endf

" Simulate `nvim_win_del_var()`
" Removes a window-scoped (w:) variable
" @param winid number
" @param name string
" @return any
func! api#win#get_var(winid, name) abort
  " TODO: work with any window
  exec 'unlet w:'..a:name
  " return setwinvar(s:winid(a:winid), a:name, v:null)
endf

" Simulate `nvim_win_get_option()`
" Gets a window option value
" @param winnr number
" @param name string
" @return any
func! api#win#get_option(winnr, name) abort
  return api#win#get_var(a:winid, '&'..a:name)
endf

" Simulate `nvim_win_set_option()`
" Sets a window option value. Passing `nil` as value deletes the option
" (only works if there's a global fallback)
" @param winnr number
" @param name string
" @param value any
" @return boolean
func! api#win#set_option(winnr, name, value) abort
  return api#win#set_var(a:winid, '&'..a:name, a:value)
endf

" Simulate `nvim_win_get_height()`
" Gets the window height
" @param winid number
" @return number
func! api#win#get_height(winid) abort
  return winheight(api#win#get_number(a:winid))
endf

" Simulate `nvim_win_get_height()`
" Sets the window height.
" @param winid number
" @param height number
func! api#win#set_height(winid, height) abort
endf

" Simulate `nvim_win_get_width()`
" Gets the window width
" @param winid number
" @return number
func! api#win#get_width(winid) abort
  return winwidth(api#win#get_number(a:winid))
endf

" Simulate `nvim_win_get_width()`
" Sets the window width. This will only succeed if the screen is split vertically.
" @param winid number
" @param width number
func! api#win#set_width(winid, width) abort
endf

" Simulate `nvim_win_get_cursor()`
" Gets the (1,0)-indexed, buffer-relative cursor position for a given window
" (different windows showing the same buffer have independent cursor positions)
" @param winid number
func! api#win#get_cursor(winid) abort
endf

" Simulate `nvim_win_set_cursor()`
" Sets the (1,0)-indexed cursor position in the window. |api-indexing| This
" scrolls the window even if it is not the current one.
" @param winid number
" @param pos number
func! api#win#set_cursor(winid, pos) abort
endf

" ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

" Go to window holding {bufnr}.
" Prefers current window; if its buffer number doesn't match,
" then will try from topleft to bottom right
" @param {bufnr} buffer number
func! api#win#goto_winbufnr(bufnr) abort
  if winbufnr(0) ==# a:bufnr
    return
  endif
  winc t
  let first=1
  while winbufnr(0) != a:bufnr && (first || winnr() != 1)
    winc w
    let first= 0
  endwhile
endf

" Find number of windows opened in the {bufnr}
" @param {bufnr} buffer number
" @return {number} number of windows open
func! api#win#num_in_buf(bufnr)
  let cnt = 0
  let winnum = 1
  while 1
    let bufnum = winbufnr(winnum)
    if bufnum < 0
      break
    endif
    if bufnum ==# a:bufnr
      let cnt = cnt + 1
    endif
    let winnum = winnum + 1
  endwhile

  return cnt
endf

" Return the buffer names of all winnrs
" @return {List<string>}
func! api#win#bufnames()
  let winnames = {}
  for winnr in range(1, winnr('$'))
    let winnames[winnr] = bufname(winbufnr(winnr))
  endfor
  return winnames
endf

" Find the `winnr` of the first normal window
func! api#win#first_usable()
  let i = 1
  while i <= winnr("$")
    let bnum = winbufnr(i)
    if bnum != -1 && getbufvar(bnum, '&buftype') ==# ''
        \ && !getwinvar(i, '&previewwindow')
        \ && (!getbufvar(bnum, '&modified') || &hidden)
      return i
    endif

    let i += 1
  endwhile
  return -1
endf

" Go to the previous window (winnr) (or any other window, if none)
func! api#win#goto_alt() abort
  let currwin = winnr()
  wincmd p
  if winnr() == currwin "window didn't change; no previous window.
    wincmd w
  endif
endf

func! api#win#get_alt_winnr() abort
  call api#win#goto_alt()
  let n = winnr()
  call api#win#goto_alt()
  return n
endf
