---@module 'usr.shared.utils.funcs'
---@description Utility functions that are used in multiple files
---@class Usr.Utils.Fn
local M = {}

local lazy = require("usr.lazy")
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'
local debounce = lazy.require("usr.lib.debounce") ---@module 'usr.lib.debounce'
local W = lazy.require("usr.api.win") ---@module 'usr.api.win'
local F = lazy.require("usr.shared.F") ---@module 'usr.shared.F'
local Table = lazy.require("usr.shared.table") ---@module 'usr.shared.table'
local ffi = require("ffi")

ffi.cdef([[
    int get_keystroke(void *dummy_ptr);
]])

-- local uva = require("uva")
-- local async = require("async")

local uv = vim.loop
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd

---Generically wrap a command/function call
---@generic A, R
---@param func string|fun(...: A): R?
---@param ... A
---@return R?
function M.wrap_fn_call(func, ...)
    local ok, res
    if type(func) == "string" then
        ok, res = pcall(cmd, func)
    elseif type(func) == "function" then
        ok, res = pcall(func, ...)
    end
    if not ok then
        log.err(res, {debug = true})
        return nil
    end
    return res
end

---Execute a command in normal mode. Equivalent to `norm! <cmd>`
---@param mode Feedkeys.mode|Feedkeys.mode[]
---@param motion string
function M.normal(mode, motion)
    mode = type(mode) == "table" and _t(mode):concat("") or mode
    api.nvim_feedkeys(M.termcodes[motion], mode, false)
end

-- Replace termcodes; e.g., t'<C-n>'
---@param str string String to be converted
---@param from_part? boolean Legacy vim parameter. Usually true
---@param do_lt? boolean Also translate `<lt>` (Ignored if special is false)
---@param special? boolean Replace keycodes, e.g., `<CR>` => `\r`
---@return string
function M.t(str, from_part, do_lt, special)
    -- vim.keycode()
    return api.nvim_replace_termcodes(
        str,
        F.if_nil(from_part, true),
        F.if_nil(do_lt, true),
        F.if_nil(special, true)
    )
end

---Wrapper to make getting the current mode easier
---@return string
function M.mode()
    return api.nvim_get_mode().mode
end

---Program to check if executable
---@param exec string
---@return boolean?
function M.executable(exec)
    vim.validate({exec = {exec, "string"}})
    return fn.executable(exec) == 1
end

---Get the output of a system command in a table
---@param cmd string|table
---@return Vector<string>
function M.get_system_output(cmd)
    return vim.split(fn.system(cmd), "\n")
end

---Get length of longest line in a buffer
---@param bufnr? bufnr
---@return line_t
function M.longest_line(bufnr)
    local count = bufnr and #api.nvim_buf_get_lines(bufnr, 0, -1, false) or fn.line("$")
    return Table.range({}, 1, count):map(function(line)
        return fn.virtcol({line, "$"})
    end):maxn()
end

---Get the SID of a file
---@param file string
---@return {name: string, sid: integer, autoload: boolean, version: integer, variables: table}
function M.get_sid(file)
    local sids = fn.getscriptinfo({name = file})
    return #sids == 1 and sids[1] or sids
end

---Run a command and center the screen
---@param command? string Command to run
---@param notify? boolean
function M.zz(command, notify)
    if command then
        local ok, msg = pcall(
            cmd.norm,
            {command, mods = {emsg_silent = true}, bang = true}
        )
        if not ok and notify then
            local err = msg and msg:match("Vim:E486: Pattern not found:.*") --[[@as string]]
            log.err(err or msg, {dprint = true})
        end
    end

    -- local topline = fn.line("w0")
    -- if topline ~= fn.line("w0") then
    --     cmd("norm! zvzz")
    -- end

    local lnum1, lcount = Rc.api.get_cursor_row(), api.nvim_buf_line_count(0)
    local zb = "keepj norm! %dzb"
    if lnum1 == lcount then
        cmd(zb:format(lnum1))
        return
    end
    cmd("norm! zvzz")
    lnum1 = Rc.api.get_cursor_row()
    cmd("norm! L")
    local lnum2 = Rc.api.get_cursor_row()
    -- fn.getwinvar(0, "&scrolloff")
    if lnum2 + vim.wo.scrolloff >= lcount then
        cmd(zb:format(lnum2))
    end
    if lnum1 ~= lnum2 then
        cmd("keepj norm! ``")
    end
end

--  ══════════════════════════════════════════════════════════════════════

do
    local notifications = {}

    ---Wrapper to send a notification
    ---@param msg string Message to notify
    ---@param level Log.Level
    ---@param opts? Notify.Opts
    function M.notify(msg, level, opts)
        level = F.unwrap_or(level, log.levels.INFO)
        local keep = function()
            return true
        end

        local _opts = ({
            [log.levels.TRACE] = {timeout = 500},
            [log.levels.DEBUG] = {timeout = 1000},
            [log.levels.INFO] = {timeout = 1000},
            [log.levels.WARN] = {timeout = 3000},
            [log.levels.ERROR] = {timeout = 5000, keep = keep},
        })[level]

        opts = vim.tbl_extend("force", _opts or {}, opts or {}) --[[@as Notify.Opts]]

        if opts.expand then
            msg = fn.expand(msg)
            opts.expand = nil
        end
        if opts.style and not opts.render then
            opts.render = opts.style
            opts.style = nil
        end

        if not opts.on_open then
            opts.syntax = F.unwrap_or(opts.syntax, true)
        end

        if opts.syntax then
            opts.on_open = log.on_open(opts.syntax)
            opts.syntax = nil
        end

        local function notify()
            if vim.g.nvim_focused then
                -- return vim.notify(msg, level, opts)
                local ok, notify = pcall(require, "notify")
                if not ok then
                    vim.defer_fn(function()
                        vim.notify(msg, level, opts)
                    end, 100)
                    return
                end
                return notify.notify(msg, level, opts --[[@as notify.Options]])
            else
                return require("desktop-notify").notify(msg, level, opts)
            end
        end

        if opts.once then
            if not notifications[msg] then
                notify()
                notifications[msg] = true
            end
        else
            notify()
        end
    end
end

---Global notify function.
---This must be defined here instead of `global.lua` due to loading order.
_G.N = setmetatable({}, {
    __index = function(super, level)
        level = F.unwrap_or(rawget(super, level), level)

        return setmetatable(
            {},
            {
                ---@param _ self
                ---@param msg string
                ---@param opts? LogDump.Opts
                __call = function(_, msg, opts)
                    opts = opts or {}
                    opts.level = level
                    super(msg, opts)
                end,
            }
        )
    end,
    ---@param _ self
    ---@param msg string
    ---@param opts? LogDump.Opts
    __call = function(_, msg, opts)
        opts = opts or {}
        opts.thread = 3
        opts.level =
            ({
                ["trace"] = 0,
                ["debug"] = 1,
                ["info"] = 2,
                ["warn"] = 3,
                ["error"] = 4,
                ["err"] = 4,
            })[opts.level] or opts.level

        log.dump(msg, opts)
    end,
})

--  ══════════════════════════════════════════════════════════════════════

---Create a temporary scratch buffer
---@param opts vim.bo
---@return bufnr
function M.buf_create_scratch(opts)
    local bufnr = api.nvim_create_buf(false, true)

    api.nvim_buf_call(bufnr, function()
        opts = vim.tbl_extend("keep", opts or {}, {
            list = false,
            number = false,
            relativenumber = false,
            buflisted = false,
            cursorline = false,
            cursorcolumn = false,
            foldcolumn = "0",
            signcolumn = "no",
            colorcolumn = "",
            swapfile = false,
            undolevels = -1,
            bufhidden = "wipe",
            winhl = "EndOfBuffer:Hidden",
        })

        for k, v in pairs(opts) do
            vim.opt_local[k] = v
        end
    end)

    return bufnr
end

---Display vim variables with `:Bufferize`
---@param var_type ("'g'"|"'b'"|"'v'"|"'w'")?
function M.dump_env(var_type)
    -- cmd.let({mods = {filter = {pattern = "[^bwv][^:]"}}})
    if var_type == nil then
        cmd.Bufferize({"let", mods = {noautocmd = true}})
        return
    end

    local v = Rc.fn.switch(var_type) {
        g = "[^bwv][^:]",
        b = "^b:",
        v = "^v:",
        w = "^w:",
        [Rc.fn.switch.Default] = "",
    }

    cmd.Bufferize({("filter /%s/ let"):format(v), mods = {noautocmd = true}})
    cmd.wincmd("j")
end

---Preserve cursor position when executing command
---@generic A, R
---@param func string|fun(...: A): R
---@param ... A
---@return R?
function M.preserve(func, ...)
    local view = W.win_save_positions(0)
    local line, col = unpack(api.nvim_win_get_cursor(0))
    local report = vim.o.report
    vim.o.report = 0

    local ok, res
    if type(func) == "string" then
        ok, res = pcall(cmd.exe, {
            ("%q"):format(("sil! keepj keepp keepm %s"):format(func)),
            mods = {keepjumps = true, keeppatterns = true, keepmarks = true},
        })
    elseif type(func) == "function" then
        ok, res = pcall(func, ...)
    end

    -- if type(func) == "string" then
    --     res = cmd.exe({("%q"):format(("sil! keepj keepp keepm %s"):format(func))})
    -- elseif type(func) == "function" then
    --     res = M.wrap_fn_call(function(...)
    --         return func(...)
    --     end, ...)
    -- end

    local lastline = fn.line("$")
    if line > lastline then
        line = lastline
    end

    -- Rc.api.set_cursor(0, line, col)
    api.nvim_win_set_cursor(0, {line, col})
    view.restore()
    vim.o.report = report
    return ok and res or nil
end

--  ══════════════════════════════════════════════════════════════════════

---API around `nvim_echo`
---"Colored echo"
M.cecho =
    (function()
        local lastmsg
        local debounced
        ---Echo a colored message in place. Overwrites lines
        ---@param msg string message to echo
        ---@param hl string highlight group to link
        ---@param history? boolean add message to history
        ---@param wait? number amount of time to wait
        return function(msg, hl, history, wait)
            history = history or true
            vim.schedule(function()
                api.nvim_echo({{msg, hl}}, history, {})
                lastmsg = Rc.api.exec_output("5message", true)
            end)
            if not debounced then
                debounced = debounce(function()
                    if lastmsg == Rc.api.exec_output("5message", true) then
                        api.nvim_echo({{"", ""}}, false, {})
                    end
                end, wait or 2500)
            end
            debounced()
        end
    end)()

---Echo string a multi-lined string
---@param msg string|string[]
---@param hl? Highlight.Group Highlight group name
---@param schedule? boolean Schedule the echo call
function M.echomln(msg, hl, schedule)
    if schedule then
        vim.schedule(function()
            M.echomln(msg, hl, false)
        end)
        return
    end

    if F.is.tbl(msg) then
        msg = _j(msg):concat("\n")
    end

    api.nvim_echo({{msg, hl}}, true, {})
end

---Clear the command line prompt
function M.clear_prompt()
    -- api.nvim_echo({{""}}, false, {})
    api.nvim_echo({}, false, {})
    cmd.redraw()
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                           str                            │
--  ╰──────────────────────────────────────────────────────────╯

---Cache the output of lambda expressions
local lambda_cache = {}

---Execute a lambda expression
---## Example
---```lua
---print(utils.lambda("x -> x + 2")(2)) -- prints: 4
---```
---@param str string
---@return function
function M.lambda(str)
    if not lambda_cache[str] then
        local args, body = str:match([[^([%w,_ ]-)%->(.-)$]])
        assert(args and body, "bad string lambda")
        local s = ([[
            return function(%s)
                return %s
            end
        ]]):format(args, body)
        lambda_cache[str] = M.dostring(s)
    end
    return lambda_cache[str]
end

---Load or `loadstring`
---@param str string
---@return fun(s: string): any
function M.dostring(str)
    return assert((loadstring or load)(str))()
end

---Simple string templating
---Example template: "${name} is ${value}"
---@param str string Template string
---@param tbl table Key-value pairs to replace in the string
---@return string
function M.str_template(str, tbl)
    return (str:gsub(
        "($%b{})",
        function(w)
            return tbl[w:sub(3, -2)] or w
        end
    ))
end

---Match a given string against multiple patterns.
---@param str string
---@param patterns string[]
---@return ... captured first match, or `nil` if no patterns matched
function M.str_match(str, patterns)
    for _, pattern in ipairs(patterns) do
        local m = {str:match(pattern)}
        if #m > 0 then
            return unpack(m)
        end
    end
end

---Remove ANSI escape sequences from a string
---@param str string
---@return string, integer
function M.remove_ansi(str)
    return str:gsub("\x1b%[[%d;]*%d[Km]", "")
end

---@param s string
---@param opt? Utils.StrQuote.Spec
---@return string
function M.str_quote(s, opt)
    ---@cast opt Utils.StrQuote.Spec
    s = tostring(s)
    opt = vim.tbl_extend("keep", opt or {}, {
        esc_fmt = [[\%s]],
        prefer_single = false,
        only_if_whitespace = false,
    }) --[[@as Utils.StrQuote.Spec]]

    if opt.only_if_whitespace and not s:find("%s") then
        return s
    end

    local primary, secondary = [["]], [[']]
    if opt.prefer_single then
        primary, secondary = [[']], [["]]
    end

    local has_primary = s:find(primary) ~= nil
    local has_secondary = s:find(secondary) ~= nil

    if has_primary and not has_secondary then
        return secondary .. s .. secondary
    else
        local _
        local esc = opt.esc_fmt:format(primary)
        -- First un-escape already escaped quotes to avoid incorrectly applied escapes.
        s, _ = s:gsub(esc:escape(), primary)
        s, _ = s:gsub(primary, esc)
        return primary .. s .. primary
    end
end

---Convert a path glob to a Lua regex
---@param glob string
---@return string
function M.glob2regex(glob)
    local pattern = glob:gsub("%.", "[%./]"):gsub("*", ".*")
    return ("%%s$"):format(pattern)
end

---If a #string is greater than a length, return an ellipses
---@param str string
---@param max_len integer
---@return string
function M.truncate(str, max_len)
    vim.validate({
        str = {str, "s", false},
        max_len = {max_len, "n", false},
    })
    return F.if_expr(
        api.nvim_strwidth(str) > max_len,
        str:sub(1, max_len) .. Rc.icons.misc.ellipsis,
        str
    )
end

---Table of escaped termcodes
---@class Termcodes
M.termcodes = setmetatable({}, {
    ---@param tbl table self
    ---@param k string termcode to retrieve
    ---@return string
    __index = function(tbl, k)
        local k_upper = k:upper()
        local v_upper = rawget(tbl, k_upper)
        local c = v_upper or M.t(k, true, false, true)
        rawset(tbl, k, c)
        if not v_upper then
            rawset(tbl, k_upper, c)
        end
        return c
    end,
})

---Expand a tab in a string
---@param str string
---@param ts number
---@param start? number
---@return string
function M.expandtab(str, ts, start)
    start = start or 1
    local new = str:sub(1, start - 1)
    -- without check type to improve performance
    -- if str and type(str) == 'string' then
    local pad = " "
    local ti = start - 1
    local i = start
    while true do
        i = str:find("\t", i, true)
        if not i then
            if ti == 0 then
                new = str
            else
                new = new .. str:sub(ti + 1)
            end
            break
        end
        if ti + 1 == i then
            new = new .. pad:rep(ts)
        else
            local append = str:sub(ti + 1, i - 1)
            new = new .. append .. pad:rep(ts - api.nvim_strwidth(append) % ts)
        end
        ti = i
        i = i + 1
    end
    -- end
    return new
end

---Print a value in lua
---@generic T : any
---@param v T Value to inspect
---@return T
function M.inspect(v)
    local s
    local t = type(v)
    if t == "nil" then
        s = "nil"
    elseif t == "userdata" then
        local ud = "<userdata"
        local ins = vim.inspect(getmetatable(v))
        local sp = ins:split("\n")
        if #sp == 1 then
            s = ("%s %s>"):format(ud, ins:gsub('"', ""))
        else
            if sp and sp[1] == "{" then
                s = ("%s> {\n%s\n}"):format(ud, unpack(sp, 2, #sp - 1))
            else
                s = ("%s>\n%s"):format(ud, unpack(sp))
            end
        end
    elseif t ~= "string" then
        s = vim.inspect(v, {depth = math.huge})
    else
        s = tostring(v)
    end
    return s
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function getchar()
    ---@diagnostic disable-next-line: undefined-field
    local nr = ffi and ffi.C.get_keystroke(nil) or fn.getchar()
    if ffi and nr == 3 then
        pcall(vim.cmd, "")
    end
    return nr
end

---@param prompt string
---@param opt Utils.InputChar.Spec
---@return string? Char
---@return string|number Raw
function M.input_char(prompt, opt)
    opt = vim.tbl_extend("keep", opt or {}, {
        clear_prompt = true,
        allow_non_ascii = false,
        loop = false,
        prompt_hl = nil,
    }) --[[@as Utils.InputChar.Spec]]

    local valid, s, raw
    while true do
        valid = true

        if prompt then
            api.nvim_echo({{prompt, opt.prompt_hl}}, false, {})
        end

        local c
        if not opt.allow_non_ascii then
            while type(c) ~= "number" do
                c = getchar()
            end
        else
            c = getchar()
        end

        if opt.clear_prompt then
            M.clear_prompt()
        end

        -- s = type(c) == "number" and fn.nr2char(c) or nil
        s = (type(c) == "number" and c > 0 and c < 128 and ("%c"):format(c)) or nil
        raw = type(c) == "number" and s or c

        if opt.filter then
            if s == nil or not s:match(opt.filter) then
                valid = false
            end
        end

        if valid or not opt.loop then
            break
        end
    end

    if not valid then
        return nil, -1
    end
    return s, raw
end

---@param prompt string
---@param opt Utils.Input.Spec
function M.input(prompt, opt)
    local completion = opt.completion
    -- if type(completion) == "function" then
    --     completion = "customlist,Config__ui_input_completion"
    -- end

    vim.ui.input({
        prompt = prompt,
        default = opt.default,
        completion = completion,
        cancelreturn = opt.cancelreturn,
    }, opt.callback)

    M.clear_prompt()
end

---@param prompt string
---@param opt Utils.Confirm.Opts
function M.confirm(prompt, opt)
    local ok, s =
        pcall(
            M.input_char,
            ("%s %s: "):format(prompt, opt.default and "[Y/n]" or "[y/N]"),
            {filter = "[yYnN\27\r]", loop = true}
        )

    M.clear_prompt()

    if not ok then
        opt.callback(false)
    else
        if s == "\27" then
            opt.callback(false); return
        end
        local value = ({
            y = true,
            n = false,
        })[(s or ""):lower()]
        if value == nil then value = opt.default end
        opt.callback(value)
    end
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---@param range Command.range
---@param ... string
function M.read_shell(range, ...)
    local args = _t({...}):map(function(v)
        return ("'%s'"):format(fn.expand(v):gsub("'", [['"'"']]))
    end):concat(" ")

    cmd(("%s r! %s"):format(F.if_expr(range[1] > 0, range[2], "."), args))
    -- fn.execute(("%s r! %s"):format(F.if_expr(range[1] > 0 , range[2] , "."), table.concat(args, " ")))
end

---@param range Command.range
---@param ... string
function M.read_ex(range, ...)
    local args = _t({...}):map(function(v)
        return fn.expand(v)
    end):concat(" ")

    local ok, ret = pcall(Rc.api.exec_output, args, true)
    if not ok then
        if ret and ret ~= "" then
            log.err(ret)
        end
        return
    end

    fn.setreg("x", ret)
    -- api.nvim_put(
    --     {
    --         F.if_expr(
    --             range[1] > 0,
    --             range[2],
    --             api.nvim_buf_get_lines(0, fn.line("."), fn.line("."), false)
    --         ),
    --     },
    --     "l",
    --     true,
    --     true
    -- )
    cmd(("%s put =@x"):format(F.if_expr(range[1] > 0, range[2], ".")))
end

function M.read_new(...)
    local args = {...}
    if #args == 0 then
        return
    end

    local prefix = args[1]:sub(1, 1) or nil
    local ex_mode, shell_mode = false, false

    cmd.enew()

    if prefix == ":" then
        ex_mode = true
        args[1] = args[1]:sub(2)
        M.read_ex({0}, unpack(args))
    elseif prefix == "!" then
        shell_mode = true
        args[1] = args[1]:sub(2)
        M.read_shell({0}, unpack(args))
    else
        cmd.read(table.concat(args, " "))
    end

    if ex_mode or shell_mode then
        vim.opt_local.ft = "log"
    end

    cmd('norm! gg"_ddG')
end

---@generic T, R
---@param msg string|nil|fun(v: T): R
---@param func fun(v: T): R
---@param ... T
---@return R
function M.perf(msg, func, ...)
    local args = {...}
    if type(msg) == "function" then
        func, args, msg = msg, {func, unpack(args)}, nil
    end
    local start = uv.hrtime()
    local data = func(...)
    local fin = uv.hrtime() - start
    vim.schedule(function()
        vim.notify(("Elapsed time: %.5fs"):format(fin), log.levels.INFO, {title = msg})
    end)
    return data
end

return M
