-- Show changes since last save
vim.cmd [[
    function! s:DiffSaved()
      let filetype=&filetype
      diffthis
      vnew | r # | normal! 1Gdd
      diffthis
      exe 'setl bt=nofile bh=wipe nobl noswf ro ft=' . filetype
    endfunction
    command! DS call s:DiffSaved()
]]

-- Hide number & sign columns to do tmux copy
vim.cmd [[
    function! s:tmux_copy_mode_toggle()
        setlocal number!
        if &signcolumn ==? 'no'
            setlocal signcolumn=auto
        else
            setlocal signcolumn=no
        endif
    endfunction
    command! TmuxCopyModeToggle call s:tmux_copy_mode_toggle()
]]
-- nnoremap <silent> <Leader>. :call system('tmux select-pane -t :.+')<cr>

-- Automatic rename of tmux window
if vim.env.TMUX ~= nil and vim.env.NORENAME == nil then
  vim.cmd [[
      augroup rename_tmux
        au!
        au BufEnter * if empty(&buftype) | let &titlestring = '' . expand('%:t') | endif
        au VimLeave * call system('tmux set-window automatic-rename on')
      augroup END
    ]]
end

-- Prevent vim clearing the system clipboard
vim.cmd [[
  if executable('xsel')
      function! PreserveClipboard()
          call system('xsel -ib', getreg('+'))
      endfunction
      function! PreserveClipboadAndSuspend()
          call PreserveClipboard()
          suspend
      endfunction
      augroup preserve_clipboard
        au!
        au VimLeave * call PreserveClipboard()
      augroup END
      nnoremap <silent> <c-z> :call PreserveClipboadAndSuspend()<cr>
      vnoremap <silent> <c-z> :<c-u>call PreserveClipboadAndSuspend()<cr>
  endif
]]
