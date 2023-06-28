let s:V = vital#vimrc#new()
let s:Msg = s:V.import('Vim.Message')

"  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

let s:large_size = 1024 * 1024 * 2
func! s:LargeFile(buf) abort
  setl noundofile
  setl norelativenumber
  setl nospell
  setl nohlsearch
  setl noshowmatch
  setl colorcolumn=
  setl foldmethod=manual
  setl lazyredraw

  " Restore settings from optimizing large files
  " au BufDelete <buffer=abuf>

  au BufDelete <buffer>
      \ setl hlsearch<
      \ | setl lazyredraw<
      \ | setl showmatch<
endf

let s:git_sourced = v:false
func! s:GitEnv(buf) abort
  if api#buf#should_exclude(a:buf)
    return
  endif

endfunc

"  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

fun! usr#core#autocmds#setup() abort
  " autocmd BufEnter * :lchdir %:p:h

  " Optimize the viewing of larger files
  augroup lmb__LargeFileEnhancement
    autocmd!
    autocmd BufRead * let size = getfsize(expand('<afile>'))
        \ | if size > s:large_size
        \ |   call s:LargeFile(expand('<abuf>'))
        \ | endif
  augroup END

  " Set git environment variables for dotfiles bare repo
  augroup lmb__GitEnv
    autocmd! BufNewFile,BufReadPost *
        \   if !api#buf#should_exclude()
        \ |   let buf = expand('<abuf>:p')
        \ | endif
  augroup END

  " augroup lmb__testing
  "   autocmd! CmdlineEnter * echomsg 'CMDLINE ENTER'
  " augroup END

  " Automatically reload buffer if changed outside current buffer
  augroup lmb__AutoRead
    autocmd!
    autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
        \   if mode() == 'n' && getcmdwintype() == ''
        \ |   checktime
        \ | endif
    autocmd BufEnter *
        \   if &buftype == '' && !&modified
        \ |   exec 'checktime '.expand('<abuf>')
        \ | endif
    autocmd FileChangedShellPost *
        \ call s:Msg.warn("File changed on disk. Buffer reloaded!")
  augroup END

  " Trim trailing lines and trailing whitespace
  augroup lmb__TrimWhitespace
    autocmd!
    autocmd BufWritePre *
        \   if !api#buf#should_exclude()
        \ |   call usr#fn#trim_whitespace()
        \ | endif
  augroup END

  if exists('##ModeChanged')
    augroup lmb__SelectModeNoYank
      autocmd!
      autocmd ModeChanged *:s set clipboard=
      autocmd ModeChanged s:* set clipboard=unnamedplus
    augroup END
  endif

  if exists('$TMUX')
    augroup lmb__RenameTmux
      autocmd!
      autocmd BufEnter *
          \   if empty(&buftype)
          \ |   set titlestring=%(%m%)%(%{expand(\"%:t\")}%)
          \ | endif
      autocmd VimLeave * let &titleold=fnamemodify(&shell, ':t')
          \ | call system('tmux setw automatic-rename on')
          \ | set t_ts=k\
          \ | call echoraw("\033]0;".hostname()."\007")
    augroup END
  endif

  " Restore cursor position when opening buffer
  augroup lmb__RestoreCursor
    autocmd!
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \     exe 'norm! g`"zvzz' |
        \ endif
  augroup END

  augroup lmb__Filetype
    autocmd!
    autocmd BufRead,BufNewFile *.ztst            setl ft=ztst
    autocmd BufRead,BufNewFile *pre-commit       setl ft=sh
    autocmd BufNewFile,BufRead coc-settings.json setl ft=jsonc
    autocmd BufRead,BufNewFile *.ms,*.me,*.mom,*.man set filetype=groff
    autocmd BufRead,BufNewFile *.tex set filetype=tex

    autocmd FileType nroff setl wrap textwidth=85 colorcolumn=+1
    autocmd Filetype json  setl shiftwidth=2 | syntax match Comment +\/\/.\+$+

    autocmd FileType text setl textwidth=78
    autocmd FileType    * call usr#core#options#formatoptions()
  augroup END

  " \ cmTitle /\v(#|--|\/\/|\%)\s*\u\w*(\s+\u\w*)*:/
  " augroup ccommtitle
  "   autocmd!
  "   autocmd Syntax * syn match
  "         \ cmTitle /\v(#|--|\/\/|\%)\s*(\u\w*|\=+)(\s+\u\w*)*(:|\s*\w*\s*\=+)/
  "         \ contained containedin=.*Comment,vimCommentTitle,rustCommentLine
  "   autocmd Syntax * syn match myTodo
  "         \ /\v(#|--|\/\/|")\s(FIXME|FIX|DISCOVER|NOTE|NOTES|INFO|OPTIMIZE|XXX|EXPLAIN|TODO|CHECK|HACK|BUG|BUGS):/
  "         \ contained containedin=.*Comment.*,vimCommentTitle
  "   " perlLabel
  "   autocmd Syntax * syn keyword cmTitle contained=Comment
  "   autocmd Syntax * syn keyword myTodo contained=Comment
  " augroup END

  " Cloe popup menu
  " augroup lmb__ClosePopup
  "   autocmd!
  "   autocmd CursorMovedI,InsertLeave *
  "         \ if pumvisible() == 0 && !&pvw && getcmdwintype() == ''| pclose | endif
  " augroup END
endfun
