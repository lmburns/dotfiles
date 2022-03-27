local map = require("common.utils").map

g.limelight_conceal_ctermfg = "gray"
g.limelight_conceal_guifg = "DarkGray"
g.limelight_paragraph_span = 1
g.limelight_priority = -1

cmd [[
  function! s:goyo_enter()
    " silent :execute 'normal! mL'
    if exists('$TMUX')
      silent !tmux set status off
      " silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
    endif
    " setl noshowmode
    " setl noshowcmd
    " setl scrolloff=999
    setl foldlevel=99
    let &background = &background
    Limelight
    " setl statusline = '%M'
    setl statusline=...%(\ [%M%R%H]%)
    hi StatusLine ctermfg=red guifg=red cterm=NONE gui=NONE
    silent :execute 'normal! <C-W>h'
  endfunction

  function! s:goyo_leave()
    if exists('$TMUX')
      silent !tmux set status on
      " silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
    endif
    Limelight!
    let &background = &background
  endfunction

  autocmd! User GoyoEnter nested call <SID>goyo_enter()
  autocmd! User GoyoLeave nested call <SID>goyo_leave()
]]

map("n", "<Leader>G", ":Goyo<CR>")
map("n", "<Leader>Li", ":Limelight!!<CR>", { silent = true })
