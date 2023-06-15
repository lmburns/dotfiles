let s:tabpagenr = { tabpage -> tabpage == 0 ? tabpagenr() : tabpage }

" Gets info of all buffers and all windows in all tabpages
" {tabnr: [{bufnr, winnr, bufname, winid}]}
" @return Dict<List>
func! api#tab#getinfo() abort
  let winid2bufnr = {}
  for bufnr in range(1, bufnr('$'))
    for winid in win_findbuf(bufnr)
      let winid2bufnr[winid] = bufnr
    endfor
  endfor

  let res = {}
  let cur_tabnr = tabpagenr()
  for tabnr in range(1, tabpagenr('$'))
    let tabinfo = []
    let cur_winnr = tabpagewinnr(tabnr)
    for winnr in range(1, tabpagewinnr(tabnr, "$"))
      let winid = win_getid(winnr, tabnr)
      let bufnr = get(winid2bufnr, winid)
      call add(tabinfo, #{bufnr: bufnr, winnr: winnr, winid: winid, bufname: bufname(bufnr)})
    endfor
    let res[tabnr] = tabinfo
  endfor

  return res
endf

" Gets the current window-number in a tabpage
" @param tabpage number
" @return winnr number
func! api#tab#get_winnr(tabpage)
  return tabpagewinnr(api#tab#get_number(a:tabpage))
endf

" Gets the buffer numbers in a tabpage
" @param tabpage 0|number
" @return List<bufnr>
func! api#tab#list_bufs(tabpage) abort
  return tabpagebuflist(s:tabpagenr(a:tabpage))
endf

" Gets the buffer numbers of visible buffers in all tabpages
" @return List<bufnr>
func! api#tab#list_all_bufs() abort
  let bufs = []
  for i in range(1, tabpagenr('$'))
    call extend(bufs, tabpagebuflist(i))
  endfor
  return bufs
endf

" Check whether {tabpage} is modified
" @param tabpage 0|number
" @return boolean
func! api#tab#is_modified(tabpage)
  let buflist = api#tab#list_bufs(a:tabpage)
  let winnr = api#tab#get_winnr(a:tabpage)
  return getbufvar(buflist[winnr - 1], '&modified')
endf

" Get the ID of a tabpage from its tab number
" @param tabnr number
" @return number?
func! api#tab#tab_nr2id(tabnr)
" for id in ipairs(api.nvim_list_tabpages()) do
"         if api.nvim_tabpage_get_number(id) == tabnr then
"             return id
"         end
"     end
endf

"  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

" Simulate `nvim_tabpage_get_number()`
" Gets the tabpage number
" @param tabpage 0|number
" @return tabpage number
func! api#tab#get_number(tabpage) abort
  return a:tabpage == 0 ? tabpagenr() : a:tabpage
endf

" Simulate `nvim_tabpage_is_valid()`
" Checks if a tabpage is valid
" @param tabpage number
" @return boolean
func! api#tab#is_valid(tabpage) abort
endf

" Simulate `nvim_get_current_tabpage()`
" Gets the current tabpage.
" @return tabpage number
func! api#tab#get_current() abort
  return tabpagenr()
endf

" Simulate `nvim_set_current_tabpage()`
" Sets the current tabpage.
" @param tabpage number
func! api#tab#set_current(tabpage) abort
endf

" Simulate `nvim_list_tabpages()`
" Gets the current list of tabpage handles.
" @return List<tabpagenr>
func! api#tab#list_tabpages() abort
  return range(1, tabpagenr("$"))
endf

" Simulate `nvim_tabpage_get_win()`
" Gets the current window-ID in a tabpage
" @param tabpage 0|number
" @return winid number
func! api#tab#get_win(tabpage) abort
  return win_getid(api#tab#get_winnr(a:tabpage))
endf

" Simulate `nvim_tabpage_list_wins()`
" Gets the windows in a tabpage
" @param tabpage 0|number
" @return List<winid>
func! api#tab#list_wins(tabpage) abort
  return map(api#tab#list_bufs(a:tabpage), 'bufwinid(v:val)')
endf

" Simulate `nvim_tabpage_get_var()`
" Gets a tab-scoped (t:) variable
" @param tabpage number
" @param name string
func! api#tab#get_var(tabpage, name) abort
  return gettabvar(s:tabpagenr(a:tabpage), a:name)
endf

" Simulate `nvim_tabpage_set_var()`
" Sets a tab-scoped (t:) variable
" @param tabpage number
" @param name string
" @param value any
func! api#tab#set_var(tabpage, name, value) abort
  return settabvar(s:tabpagenr(a:tabpage), a:name, a:value)
endf

" Simulate `nvim_tabpage_del_var()`
" Removes a tab-scoped (t:) variable
" @param tabpage number
" @param name string
func! api#tab#del_var(tabpage, name) abort
  " TODO: work with any tab
  exec 'unlet t:'..a:name
  " return settabvar(s:tabpagenr(a:tabpage), a:name, v:null)
endf
