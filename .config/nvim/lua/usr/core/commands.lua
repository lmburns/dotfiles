---@module 'usr.core.commands'
local M = {}

local lazy = require("usr.lazy")
local lib = Rc.lib
local log = lib.log
local builtin = lib.builtin

local C = Rc.shared.C
local utils = Rc.shared.utils
local xprequire = utils.mod.xprequire

-- local T = Rc.api.tab
local W = Rc.api.win
local B = Rc.api.buf
local map = Rc.api.map
local augroup = Rc.api.augroup
local command = Rc.api.command

local arg_parser = lazy.require("diffview.arg_parser") ---@module 'diffview.arg_parser'

local cmd = vim.cmd
local fn = vim.fn
local api = vim.api
local fs = vim.fs

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
command("BufCleanEmpty", B.buf_clean_empty, {desc = "Remove empty buffers from stack"})
command("BufCleanHidden", B.buf_clean_hidden, {desc = "Remove hidden buffers from stack"})
command("Wins", W.windows, {desc = "Show window information"})
command("SQV", lib.fn.print_hi_group, {desc = "Show non-treesitter HL groups"})
command("SQT", lib.fn.print_hi_group_ts, {desc = "Show treesitter HL groups"})
command("SQA", lib.fn.print_hi_group_all, {desc = "Show all HL groups"})
command("DiffSaved", lib.fn.diffsaved, {desc = "Diff file against saved"})
command("TmuxCopyModeToggle", lib.fn.tmux_copy_mode_toggle, {desc = "Copy with tmux"})
command(
    "SqueezeBlanks",
    lib.fn.squeeze_blank_lines,
    {
        range = "%",
        addr = "lines",
        nargs = "?",
        preview = lib.fn.squeeze_blanks_preview,
        desc = "Remove duplicate blank lines",
    }
)
command("SplitOn", function(c)
    lib.fn.split_on_pattern(c.args, pack_range(c), c.bang)
end, {bar = true, range = "%", addr = "lines", bang = true, nargs = "?"})

command(
    "FollowSymlink",
    function(a)
        require("usr.shared.utils.fs").follow_symlink(a.fargs[1], a.fargs[2])
    end,
    {nargs = "?", complete = "buffer", desc = "Follow buffer's symlink"}
)
command(
    "RmAnsi",
    [[<line1>,<line2>s/\%x1b\[[0-9;]*[Km]//g]],
    {range = "%", addr = "lines", nargs = "?", desc = "Remove ANSI escape sequences"}
)
command(
    "RmCtrl",
    [=[<line1>,<line2>s/[[:cntrl:]]//g]=],
    {range = "%", addr = "lines", nargs = "?", desc = "Remove control characters"}
)
-- [[<line1>,<line2>s/\<\u\|\l\u/\= join(split(tolower(submatch(0)), '\zs'), '_')/gc]],
-- [[<line1>,<line2>s#\(\<\u\l\+\|\l\+\)\(\u\)#\l\1_\l\2#g]], -- no nums in name
command(
    "Camel2Snake",
    [[<line1>,<line2>s/\v\C(<\u[a-z0-9]+|[a-z0-9]+)(\u)/\l\1_\l\2/g]],
    {range = "%", addr = "lines", nargs = "?", desc = "Convert camelCase to snake_case"}
)
command(
    "SnakeScreaming2Camel",
    [[<line1>,<line2>s/\v_*(\u)(\u*)/\1\L\2/g]],
    {range = "%", addr = "lines", nargs = "?", desc = "Convert SNAKE_CASE to camelCase"}
)
command(
    "Snake2Camel",
    [[<line1>,<line2>s/\v([A-Za-z0-9]+)_([0-9a-z])/\1\U\2/gc]],
    {range = "%", addr = "lines", nargs = "?", desc = "Convert snake_case to camelCase"}
)
-- Undo Pascal converting __func__
-- [[<line1>,<line2>s/\C_[A-Z][a-z]*__/\="_".tolower(submatch(0))]],
command(
    "Snake2Pascal",
    [[<line1>,<line2>s/\v(%(<\l+)%(_)\@=)|_(\l)/\u\1\2/g]],
    {range = "%", addr = "lines", nargs = "?", desc = "Convert snake_case to PascalCase"}
)
command(
    "Tags2Upper",
    [[<line1>,<line2>s/<\/\=\(\w\+\)\>/\U&/g]],
    {range = "%", addr = "lines", nargs = "?", desc = "Convert tags to UPPERCASE"}
)
command(
    "Tags2Lower",
    [[<line1>,<line2>s/<\/\=\(\w\+\)\>/\L&/g]],
    {range = "%", addr = "lines", nargs = "?", desc = "Convert tags to lowercase"}
)
command(
    "Reverse",
    [[<line1>,<line2>g/^/m<line1>-1]],
    {range = "%", addr = "lines", nargs = "?", bar = true, desc = "Reverse the selected lines"}
)
command(
    "Tab2Space",
    [[execute '<line1>,<line2>s#^\t\+#\=repeat(" ", len(submatch(0))*' . &ts . ')']],
    {range = "%", addr = "lines", nargs = "?", desc = "Convert tabs to spaces"}
)
command(
    "Space2Tab",
    [[execute '<line1>,<line2>s#^\( \{'.&ts.'\}\)\+#\=repeat("\t", len(submatch(0))/' . &ts . ')']],
    {range = "%", addr = "lines", nargs = "?", desc = "Convert spaces to tabs"}
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
command("Vimrc", function(opts)
    if opts.args == "" then
        cmd.edit("$NVIMRC")
    else
        local path = fs.find(fn.fnamemodify(opts.args, ":t"), {path = Rc.dirs.config_l, limit = 1})
                       [1]
        if not path then
            api.nvim_err_writeln(("[Nvimrc]: %s.lua not found"):format(opts.args))
            return
        end
        cmd.edit(path)
    end

    cmd.lcd(Rc.dirs.config)
end, {
    nargs = "?",
    complete = function(line)
        ---@diagnostic disable: param-type-mismatch
        local paths = _j(fn.globpath(Rc.dirs.config_l, "**/*.lua", true, true))
        return paths:fmap(function(p)
            if vim.startswith(p, line) then
                return fn.fnamemodify(p, (":s?%s/??"):format(Rc.dirs.config_l))
            end
        end)
    end,
})
command("CursorNodes", function()
    local node = require("nvim-treesitter.ts_utils").get_node_at_cursor()
    while node do
        p(node:type())
        node = node:parent()
    end
end, {nargs = 0, desc = "Show treesitter nodes"})

command(
    "ReadEx",
    function(a)
        utils.read_ex(pack_range(a), unpack(a.fargs))
    end,
    {
        nargs = "*",
        range = "%",
        addr = "lines",
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
                        C.vec_join(
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
        Rc.api.set_cursor(0, 1, 0)
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
        Rc.api.set_cursor(0, 1, 0)
    end,
    {nargs = "*", bar = true, desc = "Alternative to 'Bufferize'"}
)

--  ══════════════════════════════════════════════════════════════════════

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
                {desc = "Execute file", lcmd = true}
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

--  ╭──────────────────────────────────────────────────────────╮
--  │                           TMUX                           │
--  ╰──────────────────────────────────────────────────────────╯

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

command(
    "Profile",
    function()
        log.info("Profiling has begun", {title = "Profile"})
        cmd.profile("start /tmp/profile.log")
        cmd.profile("file *")
        cmd.profile("func *")
        -- Rc.api.del_keymap("n", ";p")
        map("n", ";p",
            function()
                cmd.profile("dump")
                cmd.profile("stop")
                log.info("Profile has been saved", {title = "Profile"})
                map("n", ";p", "Profile", {unmap = true, cmd = true, desc = "Start profiling"})
            end, {desc = "Finish profiling"})
    end,
    {desc = "Begin profiling to /tmp/profile.log. ';p' to finish"}
)

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

return M
