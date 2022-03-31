local utils = require("common.utils")
local map = utils.map
local autocmd = utils.autocmd
local create_augroup = utils.create_augroup

-- ============================ Commands ============================== [[[
cmd [[
    command! -range=% -nargs=0 RmAnsi <line1>,<line2>s/\%x1b\[[0-9;]*[Km]//g
    command! -nargs=? -complete=buffer FollowSymlink lua require('common.kutils').follow_symlink(<f-args>)
    command! -nargs=0 CleanEmptyBuf lua require('common.kutils').clean_empty_bufs()
    command! -nargs=0 Jumps lua require('common.builtin').jumps2qf()
]]
-- ]]] === Commands ===

-- ============================ Functions ============================= [[[
-- ============================== Syntax ============================== [[[
-- Show syntax group
cmd [[
  function! SynStack() abort
    if !exists("*synstack")
      return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
  endfunction

  command! Synstack call SynStack()
]]

-- Display the syntax stack at current cursor position
cmd [[
  function! SyntaxQuery() abort
    for id in synstack(line("."), col("."))
      execute 'hi' synIDattr(id, "name")
    endfor
  endfunction

  command! SQ call SyntaxQuery()

  nnoremap <Leader>sll :syn list<
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

-- ========================= Builtin Terminal ========================= [[[
g.term_buf = 0
g.term_win = 0

cmd [[
  function! TermToggle(height)
    if win_gotoid(g:term_win)
        hide
    else
        botright new
        exec "resize " . a:height
        try
            exec "buffer " . g:term_buf
        catch
            call termopen("zsh", {"detach": 0})
            let g:term_buf = bufnr("")
            set nonumber
            set norelativenumber
            set signcolumn=no
        endtry
        startinsert!
        let g:term_win = win_getid()
    endif
  endfunction
]]

cmd [[command! -nargs=* TP botright sp | resize 20 | term <args>]]
cmd [[command! -nargs=* VT vsp | term <args>]]

-- map("n", "<A-i>", ":TP<CR>A")
-- Toggle terminal on/off (neovim)
map("n", "<C-t>", ":call TermToggle(12)<CR>")
map("i", "<C-t>", "<Esc>:call TermToggle(12)<CR>")
map("t", "<C-t>", [[<C-\><C-n>:call TermToggle(12)<CR>]])

-- Terminal go back to normal mode
map("t", "<Esc>", [[<C-\><C-n>]])
map("t", ":q!", [[<C-\><C-n>:q!<CR>]])
-- ]]] === Terminal ===

-- ========================== Execute Buffer ========================== [[[
cmd [[
  function! s:execute_buffer()
    if !empty(expand('%'))
        write
        call system('chmod +x '.expand('%'))
        silent e
        vsplit | terminal ./%
    else
        echohl WarningMsg
        echo 'Save the file first'
        echohl None
    endif
  endfunction

  command! RUN :call s:execute_buffer()
]]

local execute_buffer = create_augroup("ExecuteBuffer")
api.nvim_create_autocmd(
    "FileType", {
      callback = function()
        map("n", "<Leader>r<CR>", ":RUN<CR>")
        map("n", "<Leader>lru", ":FloatermNew --autoclose=0 ./%<CR>")
      end,
      pattern = { "sh", "bash", "zsh", "python", "ruby", "perl", "lua" },
      group = execute_buffer,
    }
)

api.nvim_create_autocmd(
    "FileType", {
      callback = function()
        map("n", "<Leader>r<CR>", ":FloatermNew tsc % && node %:r.js <CR>")
      end,
      pattern = { "typescript" },
      group = execute_buffer,
    }
)

api.nvim_create_autocmd(
    "FileType", {
      callback = function()
        map("n", "<Leader>r<CR>", ":FloatermNew node % <CR>")
      end,
      pattern = { "javascript" },
      group = execute_buffer,
    }
)
-- ]]] === Execute Buffer ===

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

  augroup gogithub
      au!
      au FileType *vim,*bash,*tmux,zsh,lua nnoremap <buffer> <silent> <leader><cr> :call <sid>go_github()<cr>
  augroup END
]]

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
