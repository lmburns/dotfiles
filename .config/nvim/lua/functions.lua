local M = {}

-- local D = require("dev")
local log = require("common.log")
local utils = require("common.utils")
local command = utils.command
local map = utils.map
local augroup = utils.augroup

local Path = require("plenary.path")

local uv = vim.loop
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

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
    {nargs = "+", complete = "file", desc = "Grep current file"}
)

command(
    "LGrep",
    function(tbl)
        ex.noautocmd(("lgrep! %s | redraw! | lcopen"):format(tbl.args))
    end,
    {nargs = "+", complete = "file", desc = "Grep location list"}
)

-- `Grepper` is used for multiple buffers, this is for one
command(
    "VG",
    function(tbl)
        cmd(([[:vimgrep '%s' %s | copen]]):format(tbl.fargs[1], tbl.fargs[2] or "%"))
    end,
    {nargs = "+", desc = "Vimgrep"}
)

command(
    "LOC",
    function(_)
        local bufnr = api.nvim_get_current_buf()
        local ft = vim.bo[bufnr].ft
        ex.lcd(fn.expand("%:p:h"))
        cmd(("!tokei -t %s %%"):format(ft))
    end,
    {nargs = 0, desc = "Tokei current file"}
)

command(
    "Jumps",
    function()
        require("common.builtin").jumps2qf()
    end,
    {nargs = 0, desc = "Show jumps in quickfix"}
)

command(
    "Changes",
    function()
        require("common.builtin").changes2qf()
    end,
    {nargs = 0, desc = "Show changes in quickfix"}
)

command(
    "CleanEmptyBuf",
    function()
        require("common.utils").clean_empty_bufs()
    end,
    {nargs = 0, desc = "Remove empty buffers from stack"}
)

command(
    "FollowSymlink",
    function(tbl)
        require("common.utils").follow_symlink(tbl.args)
    end,
    {nargs = "?", complete = "buffer", desc = "Follow buffer's symlink"}
)

command(
    "RmAnsi",
    [[<line1>,<line2>s/\%x1b\[[0-9;]*[Km]//g]],
    {nargs = 0, range = "%", desc = "Remove ANSI escape sequences"}
)
-- ]]] === Commands ===

-- ============================ Functions ============================= [[[
-- ============================== Syntax ============================== [[[
map("n", "<Leader>sll", ":syn list")
map("n", "<Leader>slo", ":verbose hi")

---Display the syntax stack at current cursor position
---@return table?
function M.name_syn_stack()
    local stack = fn.synstack(fn.line("."), fn.col("."))
    stack =
        vim.tbl_map(
        function(v)
            return fn.synIDattr(v, "name")
        end,
        stack
    ) --[[@as table]]
    return stack
end

---Display the syntax group at current cursor position
function M.print_syn_group()
    local id = fn.synID(fn.line("."), fn.col("."), 1)
    nvim.echo({{"Synstack: ", "WarningMsg"}, {vim.inspect(M.name_syn_stack())}})
    nvim.echo({{fn.synIDattr(id, "name"), "WarningMsg"}, {" => "}, {fn.synIDattr(fn.synIDtrans(id), "name")}})
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
    end,
    {desc = "Show highlight group (non-treesitter)"}
)
-- ]]] === Syntax ===

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
    end,
    {desc = "Show diff of saved file"}
)

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Open Links/Files                     │
-- ╰──────────────────────────────────────────────────────────╯
---Supports plugin names commonly found in `zinit`, `packer`, `Plug`, etc.
---Will open something like 'lmburns/lf.nvim' and if that fails will open an actual url
---Generic open function used with other functions
function M.open(path)
    fn.jobstart({"handlr", "open", path}, {detach = true})
    vim.notify(("Opening %s"):format(path), log.levels.WARN)
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
    if path:match("https?://") then
        return vim.cmd("norm gx")
    end

    -- Check whether it is a file
    -- Expand relative links, e.g., ../lua/abbr.lua
    local abs = Path:new(path):absolute()
    if uv.fs_stat(abs) then
        return vim.cmd("norm! gf")
    end

    -- Any URI with a protocol segment
    local protocol_uri_regex = "%a*:%/%/[%a%d%#%[%]%-%%+:;!$@/?&=_.,~*()]*"
    if path:match(protocol_uri_regex) then
        return vim.cmd("norm! gf")
    end

    -- Consider anything that looks like string/string a github link
    local plugin_url_regex = "[%a%d%-%.%_]*%/[%a%d%-%.%_]*"
    local link = path:match(plugin_url_regex)
    -- Check to make sure a path doesn't accidentally get picked up
    local num_slashes = #vim.split(path, "/") - 1
    if link and num_slashes == 1 then
        return M.open(("https://www.github.com/%s"):format(link))
    end
    return vim.cmd("norm! gf")
    -- M.open(path)
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
map("n", "<C-,>,", M.modify_line_end_delimiter(","), {desc = "Add comma to eol"})
map("n", "<C-,>;", M.modify_line_end_delimiter(";"), {desc = "Add semicolon to eol"})

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

---Add an empty line above the cursor
function M.empty_line_above()
    M.insert_empty_lines(vim.v.count, -1)
end

---Add an empty line below the cursor
function M.empty_line_below()
    M.insert_empty_lines(vim.v.count, 0)
end

map(
    "n",
    "zk",
    function()
        vim.opt.opfunc = "v:lua.require'functions'.empty_line_above"
        return "g@l"
    end,
    {expr = true, desc = "Insert empty line above"}
)

map(
    "n",
    "zj",
    function()
        -- M.insert_empty_lines(vim.v.count, 0)
        vim.opt.opfunc = "v:lua.require'functions'.empty_line_below"
        return "g@l"
    end,
    {expr = true, desc = "Insert empty line below"}
)

-- Not have to wait for normal o/O command
-- map("n", "oa", "<cmd>norm! O<CR>i")
-- map("n", "os", "<cmd>norm! o<CR>i")

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
    -- opt_local.number = not opt_local.number
    -- opt_local.rnu = not opt_local.rnu

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
    {nargs = 0, desc = "Toggle line numbers to copy with tmux"}
)

-- map(
--     "n", "<Leader>.", ":call system('tmux select-pane -t :.+')<cr>",
--     { silent = true }
-- )

-- Prevent vim clearing the system clipboard
if fn.executable("xsel") then
    -- Doesn't call xsel. Vimscript version works
    function M.preserve_clipboard()
        fn.system("xsel -ib", nvim.reg["+"])
    end

    function M.preserve_clipboard_and_suspend()
        M.preserve_clipboard()
        vim.cmd("suspend")
        -- ex.suspend()
    end

    nvim.autocmd.lmb__PreserveClipboard = {
        event = "VimLeave",
        pattern = "*",
        command = function()
            M.preserve_clipboard()
        end
    }

    map({"n", "v"}, "<C-z>", dev.ithunk(M.preserve_clipboard_and_suspend))
end
-- ]]] === Functions ===

return M
