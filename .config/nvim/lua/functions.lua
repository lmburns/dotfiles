local M = {}

local utils = require("common.utils")
local command = utils.command
local map = utils.map
local au = utils.au
local augroup = utils.augroup

-- ============================ Commands ============================== [[[

command(
    "NvimRestart",
    function()
        if not pcall(require, "nvim-reload") then
            require("packer").loader("nvim-reload")
        end
        local reload = R("plugs.nvim-reload")
        -- R("nvim-reload").Restart()
        reload.Restart()
    end,
    {nargs = "*"}
)

command(
    "Grep",
    function(tbl)
        api.nvim_exec(([[noautocmd grep! %s | redraw! | copen]]):format(tbl.args), true)
    end,
    {nargs = "+", complete = "file"}
)

command(
    "LGrep",
    function(tbl)
        api.nvim_exec(([[noautocmd lgrep! %s | redraw! | lopen]]):format(tbl.args), true)
    end,
    {nargs = "+", complete = "file"}
)

command(
    "Jumps",
    function()
        require("common.builtin").jumps2qf()
    end,
    {nargs = 0}
)

command(
    "CleanEmptyBuf",
    function()
        require("common.kutils").clean_empty_bufs()
    end,
    {nargs = 0}
)

command(
    "FollowSymlink",
    function(tbl)
        require("common.kutils").follow_symlink(tbl.args)
    end,
    {nargs = "?", complete = "buffer"}
)

command("RmAnsi", [[<line1>,<line2>s/\%x1b\[[0-9;]*[Km]//g]], {nargs = 0, range = "%"})

-- `Grepper` is used for multiple buffers, this is for one
command(
    "VG",
    function(tbl)
        cmd(([[:vimgrep '%s' %s | copen]]):format(tbl.fargs[1], tbl.fargs[2] or "%"))
    end,
    {nargs = "+"}
)
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
-- ]]] === Syntax ===

-- ========================= Builtin Terminal ========================= [[[
g.term_buf = 0
g.term_win = 0

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

cmd [[
  function! LuaExecutor() abort
    if &ft == 'lua'
      call execute(printf(":lua %s", getline(".")))
    elseif &ft == 'vim'
      exe getline(">")
    endif
  endfunction

 if !exists('*SaveAndExec')
    function! SaveAndExec() abort
      if &filetype == 'vim'
        :silent! write
        :source %
      elseif &filetype == 'lua'
        :silent! write
        :luafile %
      endif
      return
    endfunction
  endif
]]

au(
    "ExecuteBuffer",
    {
        {
            "FileType",
            {"sh", "bash", "zsh", "python", "ruby", "perl", "lua"},
            function()
                map("n", "<Leader>r<CR>", ":RUN<CR>")
                map("n", "<Leader>lru", ":FloatermNew --autoclose=0 ./%<CR>")
            end
        },
        {
            "FileType",
            "typescript",
            function()
                map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 tsc --target es6 % && node %:r.js<CR>")
                -- map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 npx ts-node %<CR>")
            end
        },
        {
            "FileType",
            "javascript",
            function()
                map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 node % <CR>")
            end
        },
        {
            "FileType",
            "lua",
            function()
                map("n", "<Leader>xl", ":luafile %<CR>")
                map("n", "<Leader>xx", ":call LuaExecutor()<CR>")
                map("v", "<Leader>xx", [[:<C-w>exe join(getline("'<","'>"),'<Bar>')<CR>]])
                map("n", "<Leader><Leader>x", ":call SaveAndExec()<CR>")
            end
        }
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
      au FileType *vim,*bash,*tmux,zsh,lua nnoremap <buffer> <silent> 1<cr> :call <sid>go_github()<cr>
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

return M
