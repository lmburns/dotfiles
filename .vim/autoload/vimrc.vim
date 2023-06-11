scriptencoding utf-8

let s:V = vital#vimrc#new()

let s:List = s:V.import('Data.List')
let s:Msg = s:V.import('Vim.Message')
let s:Promise = s:V.import('Async.Promise')

" Allows to reuse `self`.
" {{{
"
" Params:
"   self: A
"   f: (self: A) -> B
"
" Result: B
"
" Example:
"   join(a:stdout, '')->vimrc#let({ result ->
"     \ result ==# foo
"       \ ? bar
"       \ : result
"    \ })
"
" }}}
function vimrc#let(self, f) abort
  return a:f(a:self)
endfunction

" Applies `f` if `p(value)`.
" {{{
"
" Params:
"   value: A
"   p: (value: A) -> Bool
"   f: (value: A) -> B
"
" Result: A | B
"
" Example:
"   let git_root = fnameescape(join(a:stdout, ''))->vimrc#apply_if(
"     \ { git_root -> (git_root !~# '^/') && executable('wslpath') },
"     \ { git_root_windows -> fnameescape(system("wslpath '%s'", git_root_windows)) },
"   \ )
"
" }}}
function vimrc#apply_if(value, p, f) abort
  return a:value->vimrc#let({ value ->
    \ a:p(value) ? a:f(value) : value
  \ })
endfunction

function vimrc#identity(x) abort
  return a:x
endfunction

" Returns a:alt if f() throws an exception.
function vimrc#catch(f, alt) abort
  try
    call a:f()
  catch
    return a:alt
  endtry
endfunction

" Converts from a Windows path to the WSL2 path if you are on WSL2.
"
" Params:
"   cont: (git_root: string) -> A
"   stdout: Array<string> | string
"   stderr: Array<string> | string
function s:parse_git_root(cont, stdout, stderr) abort
  if type(a:stderr) is type([]) && a:stderr !=# []
    throw join(a:stderr)
  endif
  if type(a:stderr) is type('') && a:stderr !=# ''
    throw a:stderr
  endif

  let stdout = type(a:stdout) is type([])
    \ ? join(a:stdout, '')
    \ : a:stdout

  " Replace to the wsl2's path if git_root is a windows path (by git.exe)
  " NOTE: -2 removes the trailing line break
  let git_root = fnameescape(stdout)->vimrc#apply_if(
    \ { git_root -> (git_root !~# '^/') && executable('wslpath') },
    \ { git_root_windows -> fnameescape(system(printf("wslpath %s", git_root_windows)))[:-3] },
  \ )
  " ^^ TODO: Use timer_start() instead of system()

  return a:cont(git_root)
endfunction

" Async
function vimrc#read_git_root(cont) abort
  call vimrc#job#start_simply(
    \ ['git', 'rev-parse', '--show-toplevel'],
    \ function('s:parse_git_root', [a:cont]),
  \ )
endfunction

function s:set_git_root_to_gvimrc(git_root) abort
  echomsg 'vimrc: a git root detected: ' .. a:git_root
  let g:vimrc.git_root = a:git_root
endfunction

function vimrc#read_to_set_git_root() abort
  call vimrc#read_git_root(function('s:set_git_root_to_gvimrc'))
endfunction

function vimrc#read_git_root_sync() abort
  const result = system('git rev-parse --show-toplevel')

  if v:shell_error
    throw 'Failed to read a git root directory'
  endif

  return result
endfunction

" Compress continuous space
function vimrc#compress_spaces()
  const recent_pattern = @/
  try
    execute 'substitute/\s\+/ /g'
    normal! ==
  finally
    let @/ = recent_pattern
  endtry
  nohlsearch
endfunction

" Clear all lines end space
function vimrc#clear_ends_space()
  const recent_pattern = @/
  const curpos = getcurpos()
  try
    execute '%substitute/\s*\?$//g'
  catch /E486/
    echo 'nothing todo'
  finally
    let @/ = recent_pattern
    call setpos('.', curpos)
  endtry
endfunction

" If you has nofile buffer, close it.
function vimrc#bufclose_filetype(filetypes)
  let closed = 0
  for w in range(1, winnr('$'))
    let buf_ft = getwinvar(w, '&filetype')
    if s:List.has(a:filetypes, buf_ft)
      execute ':' .. w .. 'wincmd w'
      quit
      let closed = 1
    endif
  endfor
  return closed
endfunction

" Toggle open netrw explorer ( vertical split )
function vimrc#toggle_explorer(...)
  const path = get(a:000, 0, expand('%:p:h'))
  const closed = vimrc#bufclose_filetype(['dirvish'])
  if !closed
    call vimrc#open_explorer('vsplit', path)
  endif
endfunction

function vimrc#open_explorer(split, ...) abort
  const path = get(a:000, 0, expand('%:p:h'))
  const cmd =
    \ a:split ==# 'stay'  ? ':Dirvish' :
    \ a:split ==# 'split' ? ':split | silent Dirvish' :
    \ a:split ==# 'vsplit' ? ':vsplit | silent Dirvish' :
    \ a:split ==# 'tabnew' ? ':tabnew | silent Dirvish' :
      \ execute('throw "an unexpected way to open the explorer: ' .. a:split .. '"')

  if !isdirectory(path)
    " :silent to ignore an error message. Because opening seems success.
    silent execute cmd
    return
  endif

  execute cmd path
endfunction

" :quit if only a window is existent,
" :hide otherwise
function vimrc#hide_or_quit() abort
  const tabnum = tabpagenr('$')
  const winnum = tabpagewinnr(tabpagenr(), '$')
  if tabnum is 1 && winnum is 1
    quit
  else
    hide
  endif
endfunction

" Puts a regsiter as stdin to the terminal buffer
function vimrc#put_as_stdin(detail) abort
  const current_bufnr = bufnr('%')
  call timer_start(0, { _ -> term_sendkeys(current_bufnr, a:detail) }, {'repeat': 1})
  return 'i'
endfunction

function vimrc#move_window_forward()
  const tabwin_num = len(tabpagebuflist())
  mark Z
  hide
  if tabwin_num isnot 1
    tabnext
  endif
  vsp
  normal! 'Z

  if foldlevel('.') > 0
    normal! zO
  endif
  normal! zz
endfunction

" Current buffer move to next tab
function vimrc#move_window_backward()
  mark Z
  hide
  tabprevious
  vsp
  normal! 'Z

  if foldlevel('.') > 0
    normal! zO
  endif
  normal! zz
endfunction

function vimrc#move_tab_prev()
  if tabpagenr() is 1
    $tabmove
  else
    tabmove -1
  endif
endfunction

function vimrc#move_tab_next()
  if tabpagenr() is tabpagenr('$')
    0tabmove
  else
    +tabmove
  endif
endfunction

" Auto set cursor position in the file
function vimrc#visit_past_position()
  const past_posit = line("'\"")
  if past_posit > 0 && past_posit <= line('$')
    execute 'normal! g`"'
  endif
endfunction

" Rename the file of current buffer
function vimrc#rename_to(new_name) abort
  const this_file = fnameescape(expand('%'))
  const new_name  = fnameescape(a:new_name)

  if fnamemodify(this_file, ':t') ==# new_name
    call s:Msg.error('New name is same old name, operation abort')
    return
  endif

  const file_editing = &modified
  if file_editing
    call s:Msg.error('Please :write this file')
    return
  endif

  const new_file = fnamemodify(this_file, ':h') .. '/' .. new_name
  const failed = rename(this_file, new_file)
  if failed
    call s:Msg.error(printf('Rename %s to %s is failed', this_file, new_file))
    return
  endif

  execute ':edit' new_file
  silent write
  silent execute ':bdelete' this_file

  echo printf('Renamed %s to %s', this_file, new_file)
endfunction

function vimrc#execute_repeatable_macro(name) abort
  const name = '@' .. a:name
  execute 'normal!' name
  call repeat#set(name)
endfunction

" Useful to check we can do `:tabclose`.
function vimrc#has_two_or_more_tabpages() abort
  return tabpagenr('$') > 1
endfunction

function s:cd_git_root(cd, git_root) abort
  echo 'vimrc: The current directory changed to: ' .. a:git_root

  if type(a:cd) is type('')
    execute a:cd a:git_root
    return
  endif

  call a:cd(a:git_root)
endfunction

" Params
"   cd: string | (git_root: string) -> void
"     a cd command. e.g. ':cd' or ':lcd'.
function vimrc#cd_git_root(cd) abort
  call vimrc#read_git_root(function('s:cd_git_root', [a:cd]))
endfunction

" :h Vital.Async.Promise-example-timer
function vimrc#wait(ms)
  return s:Promise.new({resolve -> timer_start(a:ms, resolve)})
endfunction
