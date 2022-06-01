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
            require("plugins").loader("nvim-reload")
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
            require("plugins").loader("nvim-reload")
        end

        require("nvim-reload").Reload()
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
    "LOC",
    function(tbl)
        local bufnr = api.nvim_get_current_buf()
        local ft = vim.bo[bufnr].ft
        ex.lcd(fn.expand("%:p:h"))
        cmd(("!tokei -t %s %%"):format(ft))
    end
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
        require("common.utils").clean_empty_bufs()
    end,
    {nargs = 0}
)

command(
    "FollowSymlink",
    function(tbl)
        require("common.utils").follow_symlink(tbl.args)
    end,
    {nargs = "?", complete = "buffer"}
)

command("RmAnsi", [[<line1>,<line2>s/\%x1b\[[0-9;]*[Km]//g]], {nargs = 0, range = "%"})

-- command(
--     "CargoBuild",
--     function(tbl)
--         local args = tbl.fargs
--         local default_config = {}
--         local config = {}
--
--         for _, val in ipairs(args) do
--             local tokens = vim.split(val, "=")
--             if #tokens == 2 then
--                 config[tokens[1]] = tokens[2]
--             end
--         end
--
--         config = vim.tbl_extend("force", default_config, config)
--
--         if args[1] == "debug" then
--             require("dev").inspect(config)
--         end
--
--         local arg = ""
--
--         for key, val in pairs(config) do
--             arg = arg .. " -" .. key .. "=" .. val
--         end
--
--         vim.cmd(("cexpr system('cargo build --message-format=short %s'"):format(arg))
--         ex.copen()
--     end,
--     {nargs = "*"}
-- )
-- ]]] === Commands ===

-- ============================ Functions ============================= [[[
-- ============================== Syntax ============================== [[[
map("n", "<Leader>sll", ":syn list")
map("n", "<Leader>slo", ":verbose hi")

---Display the syntax stack at current cursor position
function M.name_syn_stack()
    local stack = fn.synstack(fn.line("."), fn.col("."))
    stack =
        vim.tbl_map(
        function(v)
            return fn.synIDattr(v, "name")
        end,
        stack
    )
    return stack
end

---Display the syntax group at current cursor position
function M.print_syn_group()
    local id = fn.synID(fn.line("."), fn.col("."), 1)
    cmd(utils.hl.WarningMsg:format("synstack", vim.inspect(M.name_syn_stack())))
    print(fn.synIDattr(id, "name") .. " -> " .. fn.synIDattr(fn.synIDtrans(id), "name"))
end

---Print syntax highlight group (e.g., 'luaFuncId      xxx links to Function')
function M.print_hi_group()
    for _, id in pairs(M.name_syn_stack()) do
        ex.hi(id)
    end
end

command(
    "SQ",
    function()
        require("functions").print_hi_group()
    end
)
-- ]]] === Syntax ===

-- ========================= Builtin Terminal ========================= [[[
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

-- function M.execute_buffer()
-- end

function M.lua_executor()
    local bufnr = api.nvim_get_current_buf()
    if vim.bo[bufnr].ft == "lua" then
        fn.execute((":lua %s"):format(api.nvim_get_current_line()))
    elseif vim.bo[bufnr].ft == "vim" then
        fn.execute(fn.getline("<"))
    end
end

cmd [[
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
        pattern = {"lua", "vim"},
        command = function()
            map("n", "<Leader>xl", ":luafile %<CR>")
            map("n", "<Leader>xx", ":lua require('functions').lua_executor()<CR>")
            map("v", "<Leader>xx", [[:<C-w>exe join(getline("'<","'>"),'<Bar>')<CR>]])
            map("n", "<Leader><Leader>x", ":call SaveAndExec()<CR>")
        end
    }
)
-- ]]] === Execute Buffer ===

function M.execute_macro_over_visual_range()
    print("@" .. fn.getcmdline())
    fn.execute(":'<,'>normal @" .. fn.nr2char(vim.fn.getchar()))
end

-- Show changes since last save
function M.diffsaved()
    local bufnr = api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].ft
    ex.diffthis()
    cmd("vnew | r # | normal! 1Gdd")
    ex.diffthis()
    fn.execute(("setl bt=nofile bh=wipe nobl noswf ro ft=%s"):format(ft))
end

command(
    "DS",
    function()
        M.diffsaved()
    end
)

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Open Links/Files                     │
-- ╰──────────────────────────────────────────────────────────╯
--CocAction('openLink')
--
-- FIX: Make better regex
---Open a github or regular link in the browser
---
---Supports plugin names commonly found in `zinit`, `packer`, `Plug`, etc.
---Will open something like 'lmburns/lf.nvim' and if that fails will open an actual url
function M.go_github()
    local repo = fn.matchstr(fn.expand("<cWORD>"), [[\v[0-9A-Za-z\-\.\_]+/[0-9A-Za-z\-\.\_]+]])
    local url =
        fn.matchstr(
        fn.expand("<cWORD>"),
        [[\v(https?:\/\/)?(www\.)?[a-zA-Z0-9\+\~\%]{1,256}\.[a-zA-Z0-9()]{1,6}([a-zA-Z0-9()\@:\%\_\+\.\~#?&\/=\-]*)]]
    )

    if #repo > 0 and #vim.split(repo, "/") == 2 then
        local new = ("https://github.com/%s"):format(repo)
        fn["openbrowser#open"](new)
    elseif #url > 0 then
        fn["openbrowser#open"](url)
    else
        fn["openbrowser#_keymap_open"]("n")
    end
end

---Generic open function used with other functions
function M.open(path)
    fn.jobstart({"handlr", "open", path}, {detach = true})
    vim.notify(("Opening %s"):format(path))
end

---Open a directory or a link
function M.open_link()
    local file = fn.expand("<cfile>")
    if fn.isdirectory(file) > 0 then
        ex.edit("file")
    else
        M.open(file)
    end
end

---Open a file or a link
function M.open_path()
    local path = fn.expand("<cfile>")
    if path:match("https://") then
        return vim.cmd("norm gx")
    end

    -- Any URI with a protocol segment
    local protocol_uri_regex = "%a*:%/%/[%a%d%#%[%]%-%%+:;!$@/?&=_.,~*()]*"
    if path:match(protocol_uri_regex) then
        return vim.cmd("norm! gf")
    end

    -- consider anything that looks like string/string a github link
    local plugin_url_regex = "[%a%d%-%.%_]*%/[%a%d%-%.%_]*"
    local link = string.match(path, plugin_url_regex)
    if link then
        return M.open(("https://www.github.com/%s"):format(link))
    end
    return vim.cmd("norm! gf")
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Line Delimiter                      │
-- ╰──────────────────────────────────────────────────────────╯
---Add a delimiter to the end of the line if the delimiter isn't already present
---If the delimiter is present, remove it
---@param character string
function M.modify_line_end_delimiter(character)
    local delimiters = {",", ";"}
    return function()
        local line = nvim.buf.line()
        local last_char = line:sub(-1)
        if last_char == character then
            nvim.set_current_line(line:sub(1, #line - 1))
        elseif vim.tbl_contains(delimiters, last_char) then
            nvim.set_current_line(line:sub(1, #line - 1) .. character)
        else
            nvim.set_current_line(line .. character)
        end
    end
end

-- map("n", "<Leader>a,", M.modify_line_end_delimiter(","), {desc = "Add comma to eol"})
-- map("n", "<Leader>a;", M.modify_line_end_delimiter(";"), {desc = "Add semicolon to eol"})
map("n", "<C-l>,", M.modify_line_end_delimiter(","), {desc = "Add comma to eol"})
map("n", "<C-l>;", M.modify_line_end_delimiter(";"), {desc = "Add semicolon to eol"})

-- ╭──────────────────────────────────────────────────────────╮
-- │                    Insert empty lines                    │
-- ╰──────────────────────────────────────────────────────────╯
-- arsham/archer.nvim
---Insert an empty line `count` lines above the cursor
---@param count number
---@param add number: Number to modify row
function M.insert_empty_lines(count, add) --{{{2
    -- ["oo"] = {"printf('m`%so<ESC>``', v:count1)", "Insert line below cursor"},
    -- ["OO"] = {"printf('m`%sO<ESC>``', v:count1)", "Insert line above cursor"}
    -- ["oo"] = {[[<cmd>put =repeat(nr2char(10), v:count1)<cr>]], "Insert line below cursor"},
    -- ["OO"] = {[[<cmd>put! =repeat(nr2char(10), v:count1)<cr>]], "Insert line below cursor"},
    local lines = {}
    for i = 1, F.if_nil(count, 1) < 1 and 1 or count do
        lines[i] = ""
    end

    local row, _ = unpack(api.nvim_win_get_cursor(0))
    local new = row + add
    api.nvim_buf_set_lines(0, new, new, false, lines)
end

function M.empty_line_above()
    M.insert_empty_lines(vim.v.count, -1)
end

function M.empty_line_below()
    M.insert_empty_lines(vim.v.count, 0)
end

map(
    "n",
    "OO",
    function()
        vim.opt.opfunc = "v:lua.require'functions'.empty_line_above"
        return "g@l"
    end,
    {expr = true, desc = "Insert empty line above"}
)

map(
    "n",
    "oo",
    function()
        -- M.insert_empty_lines(vim.v.count, 0)
        vim.opt.opfunc = "v:lua.require'functions'.empty_line_below"
        return "g@l"
    end,
    {expr = true, desc = "Insert empty line below"}
)

---When not to use the `mkview` command for an autocmd
function M.makeview()
    local bufnr = api.nvim_get_current_buf()
    if vim.bo[bufnr].bt ~= "" or fn.empty(fn.expand("%:p")) == 1 or not vim.o.modifiable then
        return false
    end
    return true
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
        fn.system("xsel -ib", fn.getreg("+"))

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
            command = function()
                M.preserve_clipboard()
            end
        }
    )

    map({"n", "v"}, "<C-z>", M.preserve_clipboard_and_suspend)
end
-- ]]] === Functions ===

return M
