---@module 'functions'
---@description  Functions/commands that are built to perform one specific task.
local M = {}

local D = require("dev")
local uva = require("uva")
local lazy = require("common.lazy")
local log = require("common.log")
local op = require("common.op")
local utils = require("common.utils")
-- local prequire = utils.mod.prequire
local xprequire = utils.mod.xprequire

local B = require("common.api.buf")
local mpi = require("common.api")
local map = mpi.map
local augroup = mpi.augroup
local command = mpi.command

local builtin = lazy.require_on_exported_call("common.builtin")

local Path = require("plenary.path")

local ol = vim.opt_local
local uv = vim.loop
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api
local F = vim.F

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Commands                         │
-- ╰──────────────────────────────────────────────────────────╯
command(
    "Grep",
    function(tbl)
        cmd(("noau grep! %s | redraw!"):format(tbl.args))
    end,
    {nargs = "+", complete = "file", desc = "Grep current file"}
)
command(
    "LGrep",
    function(tbl)
        cmd(("noau lgrep! %s | redraw! | lcopen"):format(tbl.args))
    end,
    {nargs = "+", complete = "file", desc = "Grep location list"}
)
command(
    "NGrep",
    function(a)
        cmd.Ggrep({("'%s' .config/nvim"):format(a.args), bang = true, mods = {noautocmd = true}})
        xprequire("noice.message.router").dismiss()
        cmd.redraw({bang = true})
        cmd.copen()
    end,
    {nargs = 1, complete = "file", desc = "Grep current file"}
)
command(
    "VG",
    function(a)
        cmd.vimgrep({
            ([[/\C%s/ %s]]):format(a.fargs[1]),
            a.fargs[2] or "%",
            bang = true,
        })
        cmd.copen()
    end,
    {nargs = "+", desc = "Vimgrep current file"}
)

command(
    "LOC",
    function(_)
        local bufnr = api.nvim_get_current_buf()
        local ft = vim.bo[bufnr].ft
        cmd.lcd(fn.expand("%:p:h"))
        cmd(("!tokei -t %s %%"):format(ft))
    end,
    {nargs = 0, desc = "Tokei current file"}
)

command("Jumps", builtin.jumps2qf, {nargs = 0, desc = "Show jumps in quickfix"})
command("Changes", builtin.changes2qf, {nargs = 0, desc = "Show changes in quickfix"})
command("CleanEmptyBuf", B.buf_clean_empty, {nargs = 0, desc = "Remove empty buffers from stack"})

command(
    "FollowSymlink",
    function(a)
        require("common.utils.fs").follow_symlink(a.fargs[1], a.fargs[2])
    end,
    {nargs = "?", complete = "buffer", desc = "Follow buffer's symlink"}
)
command(
    "RmAnsi",
    [[<line1>,<line2>s/\%x1b\[[0-9;]*[Km]//g]],
    {nargs = 0, range = "%", desc = "Remove ANSI escape sequences"}
)
command(
    "RmCtrl",
    [=[<line1>,<line2>s/[[:cntrl:]]//g]=],
    {nargs = 0, range = "%", desc = "Remove control characters"}
)
command(
    "Camel2Snake",
    [[<line1>,<line2>s/\<\u\|\l\u/\= join(split(tolower(submatch(0)), '\zs'), '_')/gc]],
    {nargs = 0, range = "%", desc = "Convert camelCase to snake_case"}
)
command(
    "Snake2Camel",
    [[<line1>,<line2>%s/\([A-Za-z0-9]\+\)_\([0-9a-z]\)/\1\U\2/gc]],
    {nargs = 0, range = "%", desc = "Convert snake_case to camelCase"}
)
command(
    "Tags2Upper",
    [[<line1>,<line2>%s/<\/\=\(\w\+\)\>/\U&/g]],
    {nargs = 0, range = "%", desc = "Convert tags to UPPERCASE"}
)
command(
    "Tags2Lower",
    [[<line1>,<line2>%s/<\/\=\(\w\+\)\>/\L&/g]],
    {nargs = 0, range = "%", desc = "Convert tags to lowercase"}
)
command(
    "Reverse",
    "<line1>,<line2>g/^/m<line1>-1",
    {range = "%", bar = true, desc = "Reverse the selected lines"}
)
command(
    "MoveWrite",
    [[<line1>,<line2>write<bang> <args> | <line1>,<line2>delete _]],
    {
        nargs    = 1,
        bang     = true,
        range    = "%",
        complete = "file",
        desc     = "Write selection to another file, placing in blackhole register",
    }
)
command(
    "MoveAppend",
    [[<line1>,<line2>write<bang> >> <args> | <line1>,<line2>delete _]],
    {
        nargs    = 1,
        bang     = true,
        range    = "%",
        complete = "file",
        desc     = "Append selection to another file, placing in blackhole register",
    }
)

--  ══════════════════════════════════════════════════════════════════════

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Syntax                          │
-- ╰──────────────────────────────────────────────────────────╯

---Display the syntax stack at current cursor position
---@return table?
function M.name_syn_stack()
    local stack = fn.synstack(fn.line("."), fn.col("."))
    stack = vim.tbl_map(
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
    nvim.echo({
        {fn.synIDattr(id, "name"), "WarningMsg"},
        {" => "},
        {fn.synIDattr(fn.synIDtrans(id), "name")},
    })
end

---Print syntax highlight group (e.g., 'luaFuncId      xxx links to Function')
function M.print_hi_group()
    for _, id in pairs(M.name_syn_stack()) do
        cmd.hi(id)
    end
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Buffer Execution                     │
-- ╰──────────────────────────────────────────────────────────╯

function M.lua_executor()
    local bufnr = api.nvim_get_current_buf()
    if vim.bo[bufnr].ft == "lua" then
        fn.execute((":lua %s"):format(api.nvim_get_current_line()))
    elseif vim.bo[bufnr].ft == "vim" then
        fn.execute(fn.getline("<"))
    end
end

---Execute the buffer. Used for interpreted languages
function M.execute_buffer()
    local f = fn.expand("%")
    if f ~= "" then
        cmd.write({mods = {silent = true}})
        fn.system("chmod +x " .. f)
        cmd.e({mods = {silent = true}})
        cmd.vsplit()
        cmd.terminal("./%")
    else
        nvim.p("Save the file first", "WarningMsg")
    end
end

augroup(
    "ExecuteBuffer",
    {
        event = "FileType",
        pattern = {"sh", "bash", "zsh", "python", "ruby", "perl", "lua"},
        command = function()
            map(
                "n",
                "<Leader>r<CR>",
                "require('functions').execute_buffer()",
                {desc = "Execute file", luacmd = true}
            )
            map(
                "n",
                "<Leader>lru",
                ":FloatermNew --autoclose=0 ./%<CR>",
                {desc = "Execute file in Floaterm"}
            )
        end,
    }
)

-- ╭──────────────────────────────────────────────────────────╮
-- │                     Open Links/Files                     │
-- ╰──────────────────────────────────────────────────────────╯

---Generic open function used with other functions
---@param path string
function M.open(path)
    fn.jobstart({"handlr", "open", path}, {detach = true})
    log.info(("Opening %s"):format(path))
end

---Open a directory or a link
function M.open_link()
    local file = fn.expand("<cfile>")
    if fn.isdirectory(file) > 0 then
        cmd.edit(file)
    else
        M.open(file)
    end
end

---Open a file or a link
---Supports plugin names commonly found in `zinit`, `packer`, `Plug`, etc.
---Will open something like 'lmburns/lf.nvim' and if that fails will open an actual url
---@return nil
function M.open_path()
    local path = fn.expand("<cfile>")
    if path:match("http[s]?://") then
        return cmd.norm({"gx", bang = true})
    end

    -- Check whether it is a file
    -- Need to switch directories before doing this to guarantee the relativity is correct
    local full = fn.expand("%:p:h")
    if uv.cwd() ~= full then
        cmd.lcd(full)
    end

    -- Expand relative links, e.g., ../lua/abbr.lua
    local abs = Path:new(path):absolute()
    uva.stat(abs)
        :thenCall(function()
            return cmd.norm({"gf", bang = true})
        end)
        :catch(function()
        end)

    -- Any URI with a protocol segment
    local protocol_uri_regex = "%a*:%/%/[%a%d%#%[%]%-%%+:;!$@/?&=_.,~*()]*"
    if path:match(protocol_uri_regex) then
        return cmd.norm({"gf", bang = true})
    end

    -- string/string = github link
    local plugin_url_regex = "[%a%d%-%.%_]*%/[%a%d%-%.%_]*"
    local link = path:match(plugin_url_regex)
    -- Check to make sure a path doesn't accidentally get picked up
    local num_slashes = #(path:split("/")) - 1
    if link and num_slashes == 1 then
        return M.open(("https://www.github.com/%s"):format(link))
    end
    return cmd.norm({"gf", bang = true})
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                      Line Delimiter                      │
-- ╰──────────────────────────────────────────────────────────╯

---Add a delimiter to the end of the line if the delimiter isn't already present
---If the delimiter is present, remove it
---@param character "','"|"';'"
---@return fun()
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
map(
    "n",
    "<C-,>,",
    M.modify_line_end_delimiter(","),
    {desc = "Add comma to eol"}
)
map(
    "n",
    "<C-,>;",
    M.modify_line_end_delimiter(";"),
    {desc = "Add semicolon to eol"}
)

-- ╭──────────────────────────────────────────────────────────╮
-- │                    Insert empty lines                    │
-- ╰──────────────────────────────────────────────────────────╯

---Insert an empty line `count` lines above the cursor
---@param add number direction to add/subtract (neg=above, pos=below)
---@param count? number
function M.insert_empty_lines(add, count) --{{{2
    -- ["oo"] = {"printf('m`%so<ESC>``', v:count1)", "Insert line below cursor"},
    -- ["OO"] = {"printf('m`%sO<ESC>``', v:count1)", "Insert line above cursor"}
    -- ["oo"] = {[[<cmd>put =repeat(nr2char(10), v:count1)<cr>]], "Insert line below cursor"},
    -- ["OO"] = {[[<cmd>put! =repeat(nr2char(10), v:count1)<cr>]], "Insert line below cursor"},
    local lines = {}
    local c = count or (F.if_expr(vim.v.count > 1, vim.v.count, 1))
    for i = 1, count or (F.if_expr(vim.v.count > 1, vim.v.count, 1)) do
        lines[i] = ""
    end

    local row, _ = unpack(api.nvim_win_get_cursor(0))
    local new = row + add
    api.nvim_buf_set_lines(0, new, new, false, lines)
end

---Add an empty line above the cursor
function M.empty_line_above()
    M.insert_empty_lines(-1)
end

---Add an empty line below the cursor
function M.empty_line_below()
    M.insert_empty_lines(0)
end

map(
    "n",
    "zk",
    D.ithunk(op.operator, {cb = "require'functions'.empty_line_above", motion = "l"}),
    {desc = "Insert empty line above"}
)
map(
    "n",
    "zj",
    D.ithunk(op.operator, {cb = "require'functions'.empty_line_below", motion = "l"}),
    {desc = "Insert empty line below"}
)

--  ╭──────────────────────────────────────────────────────────╮
--  │                           TMUX                           │
--  ╰──────────────────────────────────────────────────────────╯

---Return the filetype icon and color
---@return string?, string?
local function fileicon()
    local name = fn.bufname()
    local icon, hl

    local devicons = D.npcall(require, "nvim-web-devicons")
    if devicons then
        icon, hl = devicons.get_icon_color(name, nil, {default = true})
    end
    return icon, hl
end

---Change tmux title string or return filename
---@return string
function M.title_string()
    local fname = fn.expand("%:t")
    local icon, hl = fileicon()
    if not hl then
        return (icon or "") .. " "
    end

    if vim.env.TMUX ~= nil then
        return ("#[fg=%s]%s %s #[fg=%s]"):format(hl, fname, icon, "#EF1D55")
    end

    return ("%s %s"):format(fname, icon)
end

-- Prevent vim clearing the system clipboard
if utils.executable("xsel") then
    -- Doesn't call xsel. Vimscript version works
    function M.preserve_clipboard()
        fn.system("xsel -ib", nvim.reg["+"])
    end

    function M.preserve_clipboard_and_suspend()
        M.preserve_clipboard()
        cmd.suspend()
    end

    nvim.autocmd.lmb__PreserveClipboard = {
        event = "VimLeave",
        pattern = "*",
        command = function()
            M.preserve_clipboard()
        end,
    }

    map({"n", "v"}, "<C-z>", M.preserve_clipboard_and_suspend)
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Other                           │
--  ╰──────────────────────────────────────────────────────────╯

---Record a macro with same keypress
---@param register string
---@return string
function M.record_macro(register)
    return F.if_expr(fn.reg_recording() == "", "q" .. register, "q")
end

---Run a command like `n`/`N` and center the screen
---@param command string Command to run
---@param notify? boolean
function M.center_next(command, notify)
    -- local view = fn.winsaveview()
    -- if view.topline ~= fn.winsaveview().topline then

    local topline = fn.line("w0")
    -- local ok, msg = pcall(utils.normal, "n", command)
    local ok, msg = pcall(
        cmd.norm,
        {command, mods = {silent = true}, bang = true}
    )

    if topline ~= fn.line("w0") then
        -- utils.normal("n", "zz")
        cmd("norm! zz")
    elseif not ok then
        if notify then
            local err = msg:match("Vim:E486: Pattern not found:.*")
            log.err(err or msg, {dprint = true})
        end
    end
end

M.set_formatopts = true

---Toggle 'r' in 'formatoptions'.
---This is the continuation of a comment on the next line
function M.toggle_formatopts_r()
    ---@diagnostic disable-next-line:undefined-field
    if ol.formatoptions:get().r then
        ol.formatoptions:append({r = false, o = false})
        M.set_formatopts = false
        log.info(("state: %s"):format(M.set_formatopts), {title = "Comment Continuation"})
    else
        ol.formatoptions:append({r = true, o = true})
        M.set_formatopts = true
        log.warn(("state: %s"):format(M.set_formatopts), {title = "Comment Continuation"})
    end
end

---Execute a macro over a given selection
function M.macro_visual()
    -- print("@" .. fn.getcmdline())
    fn.execute(":'<,'>normal @" .. fn.nr2char(fn.getchar()))
    -- local regions = op.get_region(fn.visualmode())
    -- local start, finish = regions.start, regions.finish
    -- cmd.norm({("@%s"):format(reg or fn.nr2char(fn.getchar())), bang = true, addr = "lines", range = {start.row, finish.row}})
    -- cmd.norm({"@q", bang = true, addr = "lines", range = {"'<", "'>"}})
end

---Show changes since last save
function M.diffsaved()
    local bufnr = api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].ft
    cmd.diffthis()
    cmd.vnew()
    cmd.r("#")
    cmd.norm({"1Gdd", bang = true})
    cmd(("setl bt=nofile bh=wipe nobl noswf ro ft=%s"):format(ft))
    cmd.diffthis()
end

-- ]]] === Functions ===
--
command("SQ", M.print_hi_group, {desc = "Show non-treesitter HL groups"})
command("DiffSaved", M.diffsaved, {desc = "Diff file against saved"})

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Cache                           │
--  ╰──────────────────────────────────────────────────────────╯

return M
