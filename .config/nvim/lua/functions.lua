---@module 'functions'
---@description  Functions/commands that are built to perform one specific task.
local M = {}

local D = require("dev")
-- local uva = require("uva")
local lazy = require("common.lazy")
local log = lazy.require("common.log") ---@module 'common.log'
local utils = require("common.utils")
local xprequire = utils.mod.xprequire

local B = lazy.require("common.api.buf") ---@module 'common.api.buf'
local mpi = require("common.api")
local map = mpi.map
local augroup = mpi.augroup
local command = mpi.command

local builtin = lazy.require("common.builtin") ---@module 'common.builtin'
local Path = lazy.require("plenary.path") ---@module 'plenary.path'
local arg_parser = lazy.require("diffview.arg_parser") ---@module 'diffview.arg_parser'

local uv = vim.loop
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api
local F = vim.F

local function pack_range(c)
    return {c.range, c.line1, c.line2}
end

local function expand_shell_arg(arg)
    local exp = fn.expand(arg) --[[@as string ]]

    if exp ~= "" and exp ~= arg then
        return utils.str_quote(exp, {only_if_whitespace = true, prefer_single = true})
    end
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Commands                         │
-- ╰──────────────────────────────────────────────────────────╯
command(
    "Cgrep",
    function(a)
        -- cmd(("noau grep! %s | redraw! | lcopen"):format(a.args))
        cmd.grep({
            ("%q"):format(a.fargs[1]),
            a.fargs[2] or "%",
            bang = true,
            mods = {noautocmd = true},
        })
        cmd.redraw({bang = true})
        cmd.copen()
    end,
    {nargs = "+", complete = "file", desc = "Grep to quickfix"}
)
command(
    "Lgrep",
    function(tbl)
        cmd(("noau lgrep! %s | redraw! | lcopen"):format(tbl.args))
    end,
    {nargs = "+", complete = "file", desc = "Grep to loclist"}
)
command(
    "Ngrep",
    function(a)
        cmd.Ggrep({("'%s' .config/nvim"):format(a.args), bang = true, mods = {noautocmd = true}})
        xprequire("noice.message.router").dismiss()
        cmd.redraw({bang = true})
        cmd.copen()
    end,
    {nargs = 1, complete = "file", desc = "Git grep neovim directory"}
)
command(
    "Vgrep",
    function(a)
        cmd.vimgrep({
            ([[/\C%s/]]):format(a.fargs[1]),
            a.fargs[2] or "%",
            bang = true,
            mods = {noautocmd = true},
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

command("Jumps", builtin.jumps2qf, {desc = "Show jumps in quickfix"})
command("Changes", builtin.changes2qf, {desc = "Show changes in quickfix"})
command("CleanEmptyBuf", B.buf_clean_empty, {desc = "Remove empty buffers from stack"})
command("SqueezeBlanks", utils.squeeze_blank_lines, {desc = "Remove duplicate blank lines"})
command("Wins", require("common.api.win").windows, {desc = "Show windows"})

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
    {range = "%", desc = "Remove ANSI escape sequences"}
)
command(
    "RmCtrl",
    [=[<line1>,<line2>s/[[:cntrl:]]//g]=],
    {range = "%", desc = "Remove control characters"}
)
-- [[<line1>,<line2>s/\<\u\|\l\u/\= join(split(tolower(submatch(0)), '\zs'), '_')/gc]],
-- [[<line1>,<line2>s#\(\<\u\l\+\|\l\+\)\(\u\)#\l\1_\l\2#g]], -- no nums in name
command(
    "Camel2Snake",
    [[<line1>,<line2>s/\v\C(<\u[a-z0-9]+|[a-z0-9]+)(\u)/\l\1_\l\2/g]],
    {range = "%", desc = "Convert camelCase to snake_case"}
)
command(
    "SnakeScreaming2Camel",
    [[<line1>,<line2>s/\v_*(\u)(\u*)/\1\L\2/g]],
    {range = "%", desc = "Convert SNAKE_CASE to camelCase"}
)
command(
    "Snake2Camel",
    [[<line1>,<line2>s/\v([A-Za-z0-9]+)_([0-9a-z])/\1\U\2/gc]],
    {range = "%", desc = "Convert snake_case to camelCase"}
)
-- Undo Pascal converting __func__
-- [[<line1>,<line2>s/\C_[A-Z][a-z]*__/\="_".tolower(submatch(0))]],
command(
    "Snake2Pascal",
    [[<line1>,<line2>s/\v(%(<\l+)%(_)\@=)|_(\l)/\u\1\2/g]],
    {range = "%", desc = "Convert snake_case to PascalCase"}
)
command(
    "Tags2Upper",
    [[<line1>,<line2>s/<\/\=\(\w\+\)\>/\U&/g]],
    {range = "%", desc = "Convert tags to UPPERCASE"}
)
command(
    "Tags2Lower",
    [[<line1>,<line2>s/<\/\=\(\w\+\)\>/\L&/g]],
    {range = "%", desc = "Convert tags to lowercase"}
)
command(
    "Reverse",
    "<line1>,<line2>g/^/m<line1>-1",
    {range = "%", bar = true, desc = "Reverse the selected lines"}
)
command(
    "Tab2Space",
    [[execute '<line1>,<line2>s#^\t\+#\=repeat(" ", len(submatch(0))*' . &ts . ')']],
    {range = "%", nargs = 0, desc = "Convert tabs to spaces"}
)
command(
    "Space2Tab",
    [[execute '<line1>,<line2>s#^\( \{'.&ts.'\}\)\+#\=repeat("\t", len(submatch(0))/' . &ts . ')']],
    {range = "%", nargs = 0, desc = "Convert spaces to tabs"}
)
command(
    "MoveWrite",
    [[<line1>,<line2>write<bang> <args> | <line1>,<line2>delete _]],
    {
        nargs    = 1,
        bang     = true,
        range    = "%",
        complete = "file",
        desc     = "Write selection to another file",
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
        desc     = "Append selection to another file",
    }
)
command(
    "DisableExcess",
    function()
        require("gitsigns").detach()
        cmd.CocDisable()
    end,
    {desc = "Disable stuff to speed up neovim"}
)
command(
    "EnableExcess",
    function()
        require("gitsigns").attach()
        cmd.CocEnable()
    end,
    {desc = "Re-enable stuff to speed up neovim"}
)
command(
    "ReadEx",
    function(a)
        utils.read_ex(pack_range(a), unpack(a.fargs))
    end,
    {
        nargs = "*",
        range = "%",
        complete = "command",
        desc = "Write output of ex command to buffer",
    }
)
command(
    "Rnew",
    function(a)
        utils.read_new(unpack(a.fargs))
    end,
    {
        nargs = "+",
        complete = function(arg_lead, cmd_line, cur_pos)
            local ctx = arg_parser.scan(cmd_line, {allow_quoted = false, cur_pos = cur_pos})
            if #ctx.args > 1 then
                local prefix = ctx.args[2]:sub(1, 1)
                if ctx.argidx == 2 then arg_lead = ctx.args[2]:sub(2) end
                if prefix == ":" then
                    return _t(fn.getcompletion(arg_lead, "command")):map(function(v)
                        return ctx.argidx == 2 and prefix .. v or v
                    end)
                elseif prefix == "!" then
                    return
                        D.vec_join(
                            expand_shell_arg(arg_lead),
                            _t(fn.getcompletion(arg_lead, "shellcmd"))
                            :map(function(v)
                                return ctx.argidx == 2 and prefix .. v or v
                            end)
                        )
                end
            end
        end,
    }
)
command(
    "HiShow",
    function()
        utils.read_new(":hi")
        local bufnr = api.nvim_get_current_buf()
        api.nvim_buf_set_name(bufnr, ("%s/Highlights"):format(fn.tempname()))
        vim.opt_local.bt = "nofile"
        mpi.set_cursor(0, 1, 0)
        cmd.ColorizerAttachToBuffer()
    end,
    {bar = true}
)
command(
    "CBufferize",
    function(a)
        utils.read_new((":%s"):format(a.args))
        local bufnr = api.nvim_get_current_buf()
        api.nvim_buf_set_name(bufnr, ("%s/Bufferize"):format(fn.tempname()))
        vim.opt_local.bt = "nofile"
        mpi.set_cursor(0, 1, 0)
    end,
    {nargs = "*", bar = true, desc = "Alternative to 'Bufferize'"}
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
    if uv.fs_stat(abs) then
        return cmd.norm({"gf", bang = true})
    end

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

---Open a file at a specific line + column.
---Example location: `foo/bar/baz:128:17`
---@param location string
function M.open_file_location(location)
    local bufnr = fn.expand("<abuf>") --[[@as number]]
    if bufnr == "" then
        return
    end

    bufnr = tonumber(bufnr)
    local l = vim.trim(location)
    local file = utils.str_match(l, {"(.*):%d+:%d+:?$", "(.*):%d+:?$", "(.*):$"})
    local line = tonumber(utils.str_match(l, {".*:(%d+):%d+:?$", ".*:(%d+):?$"}))
    local col = tonumber(l:match(".*:%d+:(%d+):?$")) or 1

    if utils.pl:readable(file) then
        cmd("keepalt edit " .. fn.fnameescape(file))
        if line then
            api.nvim_exec_autocmds("BufRead", {})
            mpi.set_cursor(0, line, col - 1)
            pcall(api.nvim_buf_delete, bufnr, {})
            pcall(cmd, ("argd %s"):format(fn.fnameescape(l)))
            -- pcall(api.nvim_exec, ("argd "):format(fn.fnameescape(l)), false)
        end
    end
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
    for i = 1, count or vim.v.count1 do
        lines[i] = ""
    end

    local row = mpi.get_cursor_row()
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

--  ╭──────────────────────────────────────────────────────────╮
--  │                           TMUX                           │
--  ╰──────────────────────────────────────────────────────────╯

---Hide number & sign columns to do tmux copy
function M.tmux_copy_mode_toggle()
    -- cmd[[setl number! rnu!]]
    vim.wo.nu = not vim.wo.nu
    vim.wo.rnu = not vim.wo.rnu

    if vim.wo.signcolumn == "no" then
        vim.wo.scl = "yes:1"
        vim.wo.fdc = "1"
    else
        vim.wo.scl = "no"
        vim.wo.fdc = "0"
    end
end

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
function M.tmux_title_string()
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

M.set_formatopts = true

---Toggle 'r' in 'formatoptions'.
---This is the continuation of a comment on the next line
function M.toggle_formatopts_r()
    ---@diagnostic disable-next-line:undefined-field
    if vim.opt_local.formatoptions:get().r then
        vim.opt_local.formatoptions:append({r = false, o = false})
        M.set_formatopts = false
        log.info(("state: %s"):format(M.set_formatopts), {title = "Comment Continuation"})
    else
        vim.opt_local.formatoptions:append({r = true, o = true})
        M.set_formatopts = true
        log.warn(("state: %s"):format(M.set_formatopts), {title = "Comment Continuation"})
    end
end

---Execute a macro over a given selection
function M.macro_visual()
    print("@" .. fn.getcmdline())
    fn.execute(":'<,'>normal @" .. fn.nr2char(fn.getchar()))

    -- local regions = op.get_region(fn.visualmode())
    -- local start, finish = regions.start, regions.finish
    -- cmd.norm({("@%s"):format(reg or fn.nr2char(fn.getchar())), bang = true, addr = "lines", range = {start.row, finish.row}})
    -- cmd.norm({"@q", bang = true, addr = "lines", range = {"'<", "'>"}})
end

---Show changes since last save
function M.diffsaved()
    local ft = api.nvim_buf_get_option(0, "filetype")
    -- cmd("tab split")
    cmd.split({mods = {tab = 1}})
    cmd.diffthis()
    cmd.vnew({mods = {split = "aboveleft"}})
    cmd.r("#")
    cmd.norm({"1Gdd", bang = true})
    cmd.diffthis()
    cmd(("setl bt=nofile bh=wipe nobl noswf ro ft=%s"):format(ft))
    cmd.wincmd("l")
end

-- ]]] === Functions ===

command("SQ", M.print_hi_group, {desc = "Show non-treesitter HL groups"})
command("DiffSaved", M.diffsaved, {desc = "Diff file against saved"})
command("TmuxCopyModeToggle", M.tmux_copy_mode_toggle, {desc = "Copy with tmux"})

command("Profile", function()
    log.info("Profiling has begun", {title = "Profile"})
    cmd.profile("start /tmp/profile.log")
    cmd.profile("file *")
    cmd.profile("func *")
    map("n", ";p", function()
        cmd.profile("dump")
        cmd.profile("stop")
        log.info("Profile has been saved", {title = "Profile"})
        -- mpi.del_keymap("n", ";p")
        map("n", ";p", "Profile", {unmap = true, cmd = true, desc = "Start profiling"})
    end, {desc = "Finish profiling"})
end, {desc = "Begin profiling to /tmp/profile.log. ';p' to finish"})

command(
    "ProfilePlenary",
    function(c)
        local profile = require("plenary.profile")
        local ctx = arg_parser.scan(c.args, {allow_quoted = false})
        local subcmd = ctx.args[1]

        if not subcmd then
            log.err("Subcommand required")
            return
        end

        if subcmd == "start" then
            local out_file = c.args[2] or "/tmp/nvim-profile"
            ---@diagnostic disable-next-line: param-type-mismatch
            profile.start(out_file, {flame = true})
        elseif subcmd == "stop" then
            profile.stop()
        end
    end, {
        nargs = "+",
        complete = function(arg_lead, cmd_line, cur_pos)
            local ctx = arg_parser.scan(cmd_line, {allow_quoted = false, cur_pos = cur_pos})
            local candidates = {}

            if ctx.argidx == 2 then
                candidates = {"start", "stop"}
            elseif ctx.argidx == 3 then
                candidates = fn.getcompletion(arg_lead, "file")
            end

            return arg_parser.process_candidates(candidates, ctx)
        end,
    })

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Cache                           │
--  ╰──────────────────────────────────────────────────────────╯

return M
