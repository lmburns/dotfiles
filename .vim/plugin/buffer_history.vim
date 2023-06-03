" ========================================================================///
" File:        buffer_history.vim
" Description: A vim plugin to maintain a buffer history per window
" Version:     1.1
" Author:      Gianmaria Bajo <mg1979@git.gmail.com>
" License:     MIT
" Modified:    lun 13 luglio 2020 14:38:50
" ========================================================================///

" Loosely based on the vim-buffer-history plugin by Dhruva Sagar (some code is
" extracted from it). Url of the original plugin:
" https://github.com/dhruvasagar/vim-buffer-history

" Options:    g:buffer_history_list_in_popup  (0)  use popup for listing too
"             g:buffer_history_short_dirs     (2)  shorten (-N) parent directories
"
" Mappings:   [w     previous buffer in window history
"             ]w     next buffer in window history
"             [W     first buffer in window history
"             ]W     last buffer in window history
"             =w     remove current buffer from window history

" INIT {{{1
if exists('g:loaded_buffer_history')
  finish
endif
let g:loaded_buffer_history = 1
let s:jumping = 0

let s:save_cpo = &cpo
set cpo&vim

function! s:init() abort
  " Init window variables. {{{2
  if !exists('w:buffer_history')
    let w:buffer_history = []
  endif
  if empty(w:buffer_history)
    let w:buffer_history_index = -1
  else
    call filter(w:buffer_history, 'buflisted(v:val)')
  endif
  return w:buffer_history_index
endfunction " }}}


" COMMANDS AND MAPPINGS {{{1
augroup BufferHistory
  au!
  autocmd BufEnter  * call buffer_history#add(winbufnr(0))
  autocmd BufUnload * call buffer_history#unload(bufnr('<afile>'))
augroup END

command!        BufferHistoryList     call buffer_history#list()
command!        BufferHistoryFirst    call buffer_history#jump(-1000)
command!        BufferHistoryLast     call buffer_history#jump(1000)
command! -count BufferHistoryBack     call buffer_history#jump(-1 * <count>)
command! -count BufferHistoryForward  call buffer_history#jump(1 * <count>)
command! -count BufferHistoryTruncate call buffer_history#truncate(<count>)
command! -count BufferHistoryRemove   call buffer_history#remove(<count>)

if get(g:, 'buffer_history_mappings', 1)
  nnoremap <silent> [w     :<C-u>BufferHistoryBack <C-r>=v:count1<CR><CR>
  nnoremap <silent> ]w     :<C-u>BufferHistoryForward <C-r>=v:count1<CR><CR>
  nnoremap <silent> [W     :<C-u>BufferHistoryFirst<CR>
  nnoremap <silent> ]W     :<C-u>BufferHistoryLast<CR>
  nnoremap <silent> -w     :<C-u>BufferHistoryRemove<CR>
endif

if get(g:, 'buffer_history_plugs', 0)
  nnoremap <silent> <Plug>(BufferHistoryBack)    :<C-u>BufferHistoryBack <C-r>=v:count1<CR><CR>
  nnoremap <silent> <Plug>(BufferHistoryForward) :<C-u>BufferHistoryForward <C-r>=v:count1<CR><CR>
endif

" }}}


function! buffer_history#add(bufnr) abort
  " Add a buffer to the history, if not present. {{{1
  call s:init()
  if s:jumping | return | endif

  try
    let index = w:buffer_history_index + 1
    if buflisted(a:bufnr) && !empty(bufname(a:bufnr)) && !isdirectory(bufname(a:bufnr))
      let bindex = index(w:buffer_history, a:bufnr)
      if bindex >= 0
        let index -= 1
        call remove(w:buffer_history, bindex)
      endif
      let w:buffer_history_index = index
      call insert(w:buffer_history, a:bufnr, index)
    endif
  catch
  endtry
endfunction " }}}


function! buffer_history#unload(bufnr)
  " Remove from history a buffer that has been unloaded. {{{1
  if s:init() == -1 | return | endif
  call filter(w:buffer_history, 'v:val !=# a:bufnr')
  if w:buffer_history_index >= len(w:buffer_history)
    let w:buffer_history_index = len(w:buffer_history) - 1
  endif
endfunction " }}}


function! buffer_history#jump(where) abort
  " Jump forward or backwards in the buffer history. {{{1
  if s:init() == -1 | return | endif
  let index = w:buffer_history_index + a:where
  if index < 0
    let index = 0
  elseif index >= len(w:buffer_history)
    let index = len(w:buffer_history) - 1
  endif
  call s:show_popup()
  let w:buffer_history_index = index
  let s:jumping = 1
  exec 'buffer' w:buffer_history[index]
  let s:jumping = 0
endfunction " }}}


function! buffer_history#vim_popup(...)
  " Show a popup with the current history, and the current position in it. {{{1
  if !exists('*popup_atcursor') | return | endif
  silent! call popup_close(s:id) " dismiss previous popup

  let [bufs, maxw]  = s:popup_buffers()
  if empty(bufs) | return | endif

  let s:id = popup_atcursor(bufs, { 'pos': 'botleft' })
  call setbufvar(winbufnr(s:id), '&filetype', 'bufhistory')
endfunction " }}}


function! buffer_history#nvim_popup(...)
  " Show a popup with the current history, and the current position in it. {{{1
  if !exists('*nvim_open_win') | return | endif
  silent! call execute('bw '.s:float) " dismiss previous popup

  let [bufs, maxw]  = s:popup_buffers()
  if empty(bufs) | return | endif

  let s:float = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(s:float, 0, -1, v:true, bufs)
  let opts = {'relative': 'cursor', 'width': maxw, 'height': len(bufs),
        \ 'col': 0, 'row': 1, 'anchor': 'NW', 'style': 'minimal'}
  let win = nvim_open_win(s:float, 0, opts)
  call setbufvar(s:float, '&filetype', 'bufhistory')
  " call nvim_win_set_option(win, 'winhl', 'Normal:Visual')
  augroup buffer_history_float
    au!
    au CursorMoved * exe 'silent!' s:float . 'bw!'
          \| exe 'au! buffer_history_float' | aug! buffer_history_float | echo "\r"
  augroup END
endfunction " }}}


function! buffer_history#list()
  " List all buffers in the history. {{{1
  if s:init() == -1 | return | endif
  if get(g:, 'buffer_history_list_in_popup', 0)
    return has('nvim') ?  buffer_history#nvim_popup() : buffer_history#vim_popup()
  endif
  let history = []
  for buf in w:buffer_history
    let mod = getbufvar(buf, '&mod') ? '+' : ''
    let current = buf == bufnr('') ? '%' : buf == bufnr('#') ? '#' : ' '
    call add(history, printf('%3d   %s%s   %s', buf, mod, current, bufname(buf)))
  endfor
  echohl Title
  echo ' nr       buffer'
  echohl None
  for b in history
    echo b
  endfor
endfunction " }}}


function! buffer_history#truncate(cnt)
  " Truncate history after current or [count] index. {{{1
  if s:init() == -1 | return | endif
  let ix = a:cnt ? a:cnt : w:buffer_history_index
  if len(w:buffer_history) > ix
    let w:buffer_history = w:buffer_history[:ix]
  endif
endfunction " }}}


function! buffer_history#remove(cnt)
  " Remove current or buffer at [count] index from history. {{{1
  if s:init() == -1 | return | endif
  if len(w:buffer_history) < 2
    echo '[buffer_history] no more buffers in history'
    return
  endif
  let ix = a:cnt ? a:cnt : w:buffer_history_index
  if len(w:buffer_history) > ix
    call remove(w:buffer_history, ix)
    buffer #
    call s:show_popup()
  endif
endfunction " }}}



" Helpers {{{1
au Syntax bufhistory call s:syntax()

fun! s:syntax()
  syn match BufhistoryCurrent '^ > .*'
  syn match BufhistoryOther   '^   .*'
  hi default link BufhistoryCurrent PmenuSel
  hi default link BufhistoryOther   Pmenu
endfun

fun! s:show_popup() abort
    call timer_start(100, has('nvim') ? 'buffer_history#nvim_popup'
          \                           : 'buffer_history#vim_popup')
endfun

fun! s:popup_buffers() abort
  let bufs  = map(copy(w:buffer_history),
        \ '(v:val == bufnr("") ? " > " : "   ") . s:short_path(v:val) . " "')
  call map(bufs, 'strwidth(v:val) > 60 ? v:val[0:3]."…".v:val[strwidth(v:val)-60:] : v:val')
  let maxw = max(map(copy(bufs), 'strwidth(v:val)'))
  return [ map(bufs, 'v:val . repeat(" ", maxw - strwidth(v:val))'), maxw ]
endfun

fun! s:short_path( bnr ) abort
  let bname = bufname(a:bnr)
  let H = fnamemodify(bname, ":~:.")

  if empty(bufname(H)) | return ''               | endif
  if has('win32')      | let H = tr(H, '\', '/') | endif
  if match(H, '/') < 0 | return H                | endif

  let is_root = H[:0] == '/'
  let splits  = split(H, '/')
  let h       = min([len(splits), get(g:, 'buffer_history_short_dirs', 2)])

  let head = splits[:-(h+1)]
  let tail = splits[-h:]
  call map(head, "substitute(v:val, '\\(.\\).*', '\\1', '')")
  let H = join(head + tail, '/')
  if is_root
    let H = '/' . H
  endif
  return H
endfun

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2 ts=2 sts=2 fdm=marker tags=tags
