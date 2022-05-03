local M = {}

local utils = require("common.utils")
local command = utils.command
local map = utils.map
local augroup = utils.augroup

-- ============================ Commands ============================== [[[

command(
    "NvimRestart",
    function()
        if not pcall(require, "nvim-reload") then
            -- require("packer").loader("nvim-reload")
            ex.PackerLoad("nvim-reload")
        end
        local reload = R("plugs.nvim-reload")
        reload.Restart()
        -- ex.PackerSync()
    end,
    {nargs = "*"}
)

command(
    "NvimReload",
    function()
        if not pcall(require, "nvim-reload") then
            ex.PackerLoad("nvim-reload")
        end
        local reload = require("nvim-reload")
        reload.Reload()
        ex.colorscheme("kimbox")
    end,
    {nargs = "*"}
)

command(
    "Grep",
    function(tbl)
        ex.noautocmd(("grep! %s | redraw! | copen"):format(tbl.args))
    end,
    {nargs = "+", complete = "file"}
)

command(
    "LGrep",
    function(tbl)
        ex.noautocmd(("lgrep! %s | redraw! | lcopen"):format(tbl.args))
    end,
    {nargs = "+", complete = "file"}
)

-- `Grepper` is used for multiple buffers, this is for one
command(
    "VG",
    function(tbl)
        cmd(([[:vimgrep '%s' %s | copen]]):format(tbl.fargs[1], tbl.fargs[2] or "%"))
    end,
    {nargs = "+"}
)

command(
    "Jumps",
    function()
        require("common.builtin").jumps2qf()
    end,
    {nargs = 0}
)

command(
    "Changes",
    function()
        require("common.builtin").changes2qf()
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

augroup(
    "ExecuteBuffer",
    {
        event = "FileType",
        pattern = {"sh", "bash", "zsh", "python", "ruby", "perl", "lua"},
        command = function()
            map("n", "<Leader>r<CR>", ":RUN<CR>")
            map("n", "<Leader>lru", ":FloatermNew --autoclose=0 ./%<CR>")
        end
    },
    {
        event = "FileType",
        pattern = "typescript",
        command = function()
            map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 tsc --target es6 % && node %:r.js<CR>")
            -- map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 npx ts-node %<CR>")
        end
    },
    {
        event = "FileType",
        pattern = "javascript",
        command = function()
            map("n", "<Leader>r<CR>", ":FloatermNew --autoclose=0 node % <CR>")
        end
    },
    {
        event = "FileType",
        pattern = "lua",
        command = function()
            map("n", "<Leader>xl", ":luafile %<CR>")
            map("n", "<Leader>xx", ":call LuaExecutor()<CR>")
            map("v", "<Leader>xx", [[:<C-w>exe join(getline("'<","'>"),'<Bar>')<CR>]])
            map("n", "<Leader><Leader>x", ":call SaveAndExec()<CR>")
        end
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

---Open a github or regular link in the browser
---
---Supports plugin names commonly found in `zinit`, `packer`, `Plug`, etc.
---Will open something like 'lmburns/lf.nvim' and if that fails will open an actual url
function M.go_github()
    local repo = fn.matchstr(fn.expand("<cWORD>"), [[\v[0-9A-Za-z\-\.\_]+/[0-9A-Za-z\-\.\_]+]])

    if #repo > 0 then
        local url = ("https://github.com/%s"):format(repo)
        fn["openbrowser#open"](url)
    else
        fn["openbrowser#_keymap_open"]("n")
    end
end

---Hide number & sign columns to do tmux copy
function M.tmux_copy_mode_toggle()
    cmd [[
        setlocal number!
        setlocal rnu!
    ]]
    if o.signcolumn:get() == "no" then
        opt_local.signcolumn = "yes:1"
    else
        opt_local.signcolumn = "no"
    end
end

command(
    "TmuxCopyModeToggle",
    function()
        require("functions").tmux_copy_mode_toggle()
    end,
    {nargs = 0}
)

-- map(
--     "n", "<Leader>.", ":call system('tmux select-pane -t :.+')<cr>",
--     { silent = true }
-- )

-- Prevent vim clearing the system clipboard
-- cmd [[
--   if executable('xsel')
--       function! PreserveClipboard()
--           call system('xsel -ib', getreg('+'))
--       endfunction
--
--       function! PreserveClipboadAndSuspend()
--           call PreserveClipboard()
--           suspend
--       endfunction
--
--       augroup preserve_clipboard
--         au!
--         au VimLeave * call PreserveClipboard()
--       augroup END
--
--       nnoremap <silent> <c-z> :call PreserveClipboadAndSuspend()<cr>
--       vnoremap <silent> <c-z> :<c-u>call PreserveClipboadAndSuspend()<cr>
--   endif
-- ]]

if fn.executable("xsel") then
    -- Doesn't call xsel. Vimscript version works
    function M.preserve_clipboard()
        -- fn.jobstart(("xsel -ib %s"):format(fn.getreg("+")))
        fn.system(("xsel -ib %s"):format(fn.getreg("+")))

        -- Job:new(
        --     {
        --         command = "xsel",
        --         args = {"-ib", fn.getreg("+").." NOPE"}
        --     }
        -- ):start()
    end

    function M.preserve_clipboard_and_suspend()
        M.preserve_clipboard()
        ex.suspend()
    end

    augroup(
        "lmb__PreserveClipboard",
        {
            event = "VimLeave",
            pattern = "*",
            command = M.preserve_clipboard
        }
    )

    map({"n", "v"}, "<C-z>", M.preserve_clipboard_and_suspend)
end
-- ]]] === Functions ===

return M
