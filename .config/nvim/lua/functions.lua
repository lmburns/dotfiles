--@module functions
---@description: Functions/commands that are built to perform one specific task.
---              They take advantage of utilities and such.

local M = {}

local D = require("dev")
local log = require("common.log")
-- local H = require("common.color")
local utils = require("common.utils")
local command = utils.command
local map = utils.map
local augroup = utils.augroup

local Path = require("plenary.path")

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
        cmd(("noau grep! %s | redraw! | copen"):format(tbl.args))
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
        cmd.lcd(fn.expand("%:p:h"))
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

command(
    "Camel2Snake",
    [[:%s/\<\u\|\l\u/\= join(split(tolower(submatch(0)), '\zs'), '_')/gc]],
    {nargs = 0, desc = "Convert camelCase to snake_case"}
)

command(
    "Snake2Camel",
    [[:%s/\([A-Za-z0-9]\+\)_\([0-9a-z]\)/\1\U\2/gc]],
    {nargs = 0, desc = "Convert snake_case to camelCase"}
)

command(
    "Reverse",
    "<line1>,<line2>g/^/m<line1>-1",
    {
        range = "%",
        bar = true,
        desc = "Reverse the selected lines"
    }
)

command(
    "MoveWrite",
    [[<line1>,<line2>write<bang> <args> | <line1>,<line2>delete _]],
    {
        nargs = 1,
        bang = true,
        range = "%",
        complete = "file",
        desc = "Write selection to another file, placing in blackhole register"
    }
)

command(
    "MoveAppend",
    [[<line1>,<line2>write<bang> >> <args> | <line1>,<line2>delete _]],
    {
        nargs = 1,
        bang = true,
        range = "%",
        complete = "file",
        desc = "Append selection to another file, placing in blackhole register"
    }
)

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Syntax                          │
-- ╰──────────────────────────────────────────────────────────╯

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
        cmd.hi(id)
    end
end

command(
    "SQ",
    function()
        require("functions").print_hi_group()
    end,
    {desc = "Show highlight group (non-treesitter)"}
)

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

function M.execute_macro_over_visual_range()
    print("@" .. fn.getcmdline())
    fn.execute(":'<,'>normal @" .. fn.nr2char(fn.getchar()))
end

-- Show changes since last save
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
        cmd.edit(file)
    else
        M.open(file)
    end
end

---Open a file or a link
function M.open_path()
    local path = fn.expand("<cfile>")
    if path:match("http[s]?://") then
        return cmd.norm("gx")
    end

    -- Check whether it is a file
    -- Need to switch directories before doing this to guarantee the relativity is correct
    local full = fn.expand("%:p:h")
    if uv.cwd() ~= full then
        cmd.lcd(full)
    end

    -- Expand relative links, e.g., ../lua/abbr.lua
    local abs = Path:new(path):absolute()
    if uv.fs_stat(abs) then
        return cmd.norm({"gf", bang = true})
    end

    -- Any URI with a protocol segment
    local protocol_uri_regex = "%a*:%/%/[%a%d%#%[%]%-%%+:;!$@/?&=_.,~*()]*"
    if path:match(protocol_uri_regex) then
        return cmd.norm({"gf", bang = true})
    end

    -- Consider anything that looks like string/string a github link
    local plugin_url_regex = "[%a%d%-%.%_]*%/[%a%d%-%.%_]*"
    local link = path:match(plugin_url_regex)
    -- Check to make sure a path doesn't accidentally get picked up
    local num_slashes = #vim.split(path, "/") - 1
    if link and num_slashes == 1 then
        return M.open(("https://www.github.com/%s"):format(link))
    end
    return cmd.norm({"gf", bang = true})
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
        vim.o.opfunc = "v:lua.require'functions'.empty_line_above"
        return "g@l"
    end,
    {expr = true, desc = "Insert empty line above"}
)

map(
    "n",
    "zj",
    function()
        -- M.insert_empty_lines(vim.v.count, 0)
        vim.o.opfunc = "v:lua.require'functions'.empty_line_below"
        return "g@l"
    end,
    {expr = true, desc = "Insert empty line below"}
)

---Run a command like `n`/`N` and center the screen
---Can be used to just center the screen
---@param command string? Option command to run
function M.center_next(command)
    local view = fn.winsaveview()

    if command then
        cmd.norm({command, mods = {silent = true}})
    end

    if view.topline ~= fn.winsaveview().topline then
        cmd.norm({"zz", mods = {silent = true}, bang = true})
    end

    -- fn.line("w$") ~= row
end

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

    if vim.o.signcolumn == "no" then
        vim.opt_local.signcolumn = "yes:1"
        vim.opt_local.foldcolumn = "1"
    else
        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"
    end
end

command(
    "TmuxCopyModeToggle",
    function()
        require("functions").tmux_copy_mode_toggle()
    end,
    {nargs = 0, desc = "Toggle line numbers to copy with tmux"}
)

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
if fn.executable("xsel") then
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
        end
    }

    map({"n", "v"}, "<C-z>", D.ithunk(M.preserve_clipboard_and_suspend))
end
-- ]]] === Functions ===

return M
