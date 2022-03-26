local utils = require("common.utils")
local map = utils.map
local autocmd = utils.autocmd

-- ============================ Commands ============================== [[[
cmd([[command! PU packadd packer.nvim | lua require('plugins').update()]])
cmd([[command! PI packadd packer.nvim | lua require('plugins').install()]])
cmd([[command! PS packadd packer.nvim | lua require('plugins').sync()]])
cmd([[command! PC packadd packer.nvim | lua require('plugins').clean()]])
-- ]]] === Commands ===

-- ============================ Functions ============================= [[[
-- ============================== Syntax ============================== [[[
-- Show syntax group
-- FIXME: Using <SID>, <SID>SynStack() ..
cmd [[
  function! s:syn_stack() abort
    if !exists("*synstack")
      return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
  endfunction
]]

-- Display the syntax stack at current cursor position
cmd [[
  function! s:syntax_query() abort
    for id in synstack(line("."), col("."))
      execute 'hi' synIDattr(id, "name")
    endfor
  endfunction

  command! SQ call s:syntax_query()

  nnoremap <Leader>sll :syn list
  nnoremap <Leader>slo :verbose hi
]]

map("n", "<Leader>sll", ":syn list")
map("n", "<Leader>slo", ":verbose hi")

map(
    "n", "<F9>",
    [[:echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<']] ..
        [[ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"]] ..
        [[ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>]]
)
-- ]]] === Syntax ===

-- Show changes since last save
cmd [[
  function! s:DiffSaved()
    let filetype=&filetype
    diffthis
    vnew | r # | normal! 1Gdd
    diffthis
    exe 'setl bt=nofile bh=wipe nobl noswf ro ft=' . filetype
  endfunction

  command! DS call s:DiffSaved()
]]

-- Open a github link in the browser
cmd [[
  function! s:go_github()
      let s:repo = matchstr(expand('<cWORD>'), '\v[0-9A-Za-z\-\.\_]+/[0-9A-Za-z\-\.\_]+')
      if empty(s:repo)
          echo 'GoGithub: No repository found.'
      else
          let s:url = 'https://github.com/' . s:repo
          " call netrw#BrowseX(s:url, 0)
          call openbrowser#open(s:url)
      end
  endfunction
]]

-- autocmd(
--     "gogithub", {
--       [[
--       FileType vim,bash,tmux,zsh,lua nnoremap <buffer> <silent> <Leader><CR> :call <sid>go_github()<CR>
--       ]],
--     }, true
-- )

-- Hide number & sign columns to do tmux copy
cmd [[
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
-- map(
--     "n", "<Leader>.", ":call system('tmux select-pane -t :.+')<cr>",
--     { silent = true }
-- )

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
-- ]]] === Functions ===
