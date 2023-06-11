" autocmd BufEnter * :lchdir %:p:h

fun! usr#core#autocmds#should_exclude(bufnr) abort
  let l:bufpath = expand('%:p')
  let l:bufname = bufname(a:bufnr)

  if l:bufpath == ''
        \ || !filereadable(l:bufpath)
        \ || l:bufname ==# '[No name]'
        \ || !buflisted(a:bufnr)
        \ || win_gettype() ==# 'popup'
    return 0
  endif
  return 1
endfun

fun! usr#core#autocmds#setup() abort
  augroup lmb__Filetype
    au!
    au BufRead,BufNewFile *.ztst            setl ft=ztst
    au BufRead,BufNewFile *pre-commit       setl ft=sh
    au BufNewFile,BufRead coc-settings.json setl ft=jsonc
    au BufRead,BufNewFile *.ms,*.me,*.mom,*.man set filetype=groff
    au BufRead,BufNewFile *.tex set filetype=tex

    au FileType nroff setl wrap textwidth=85 colorcolumn=+1
    au Filetype json  setl shiftwidth=2 | syntax match Comment +\/\/.\+$+

    au FileType text setl textwidth=78
    au FileType    * call usr#core#options#formatoptions()
  augroup END

  " Cloe popup menu
  " aug lmb__ClosePopup
  "   au!
  "   au CursorMovedI,InsertLeave *
  "         \ if pumvisible() == 0 && !&pvw && getcmdwintype() == ''| pclose | endif
  " aug END

  " Automatically reload buffer if changed outside current buffer
  augroup lmb__AutoRead
    autocmd!
    au FocusGained,BufEnter,CursorHold,CursorHoldI *
          \ if mode() == 'n' && getcmdwintype() == '' | checktime | endif
    au BufEnter *
          \ if &buftype == '' && !&modified | exec 'checktime '.expand('<abuf>') | endif
    au FileChangedShellPost * echohl WarningMsg
          \ | echo "File changed on disk. Buffer reloaded!" | echohl None
  augroup END

  " Trim trailing lines and trailing whitespace
  augroup lmb__TrimWhitespace
    au!
    au BufWritePre *
          \ if !usr#core#autocmds#should_exclude('<abuf>') | call usr#fn#trim_whitespace() | endif
  augroup END

  if exists('##ModeChanged')
    augroup lmb__SelectModeNoYank
      au!
      au ModeChanged *:s set clipboard=
      au ModeChanged s:* set clipboard=unnamedplus
    augroup END
  endif

  if exists('$TMUX')
    augroup lmb__RenameTmux
      au!
      " au BufReadPost,FileReadPost,BufNewFile *
      au BufEnter * if empty(&buftype) |
            \ set titlestring=%(%m%)%(%{expand(\"%:t\")}%)

      " \ call system('tmux set window-status-current-format ') |
      " \ call system("tmux rename-window zsh") |
      au VimLeave *
            \ let &titleold=fnamemodify(&shell, ':t') |
            \ call system('tmux setw automatic-rename on') |
            \ set t_ts=k\ |
            \ call echoraw("\033]0;".hostname()."\007")
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
endfun
