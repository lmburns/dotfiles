---@module 'usr.shared.utils.funcs'
---@description Utility functions that are used in multiple files
---@class Usr.Utils.Fn
local M = {}

local lazy = require("usr.lazy")
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'
local debounce = lazy.require("usr.lib.debounce") ---@module 'usr.lib.debounce'
local W = lazy.require("usr.api.win") ---@module 'usr.api.win'
local F = require("usr.shared").F
local Table = require("usr.shared").table

-- local uva = require("uva")
-- local async = require("async")
-- local uv = vim.loop

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
    end
    return ok and res or nil
end

---Execute a command in normal mode. Equivalent to `norm! <cmd>`
---@param mode Feedkeys.mode|Feedkeys.mode[]
---@param motion string
function M.normal(mode, motion)
    mode = type(mode) == "table" and _t(mode):concat("") or mode
    api.nvim_feedkeys(M.termcodes[motion], mode, false)
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
    ---@param level number
    ---@param opts? NotifyOpts
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

        opts = vim.tbl_extend("force", _opts or {}, opts or {}) --[[@as NotifyOpts]]

        if opts.expand then
            msg = fn.expand(msg)
            opts.expand = nil
        end
        if opts.style and not opts.render then
            opts.render = opts.style
            opts.style = nil
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
                ---@param opts? LogDumpOpts
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
    ---@param opts? LogDumpOpts
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

    -- cmd.exe({
    --     ("%q"):format(("keepj keepp keepm %s"):format(args)),
    --     mods = {keepjumps = true, keeppatterns = true, keepmarks = true},
    -- })
    -- cmd.exe({"'sil! keepj keepp %s/\\s\\+$//ge'"})
    -- lockmarks

    local res = M.wrap_fn_call(function(...)
        if type(func) == "string" then
            return cmd.exe({("%q"):format(("sil! keepj keepp keepm %s"):format(func))})
        elseif type(func) == "function" then
            return func(...)
        end
    end, ...)

    local lastline = fn.line("$")
    if line > lastline then
        line = lastline
    end

    Rc.api.set_cursor(0, line, col)
    view.restore()
    vim.o.report = report
    return res
end

--  ══════════════════════════════════════════════════════════════════════

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

---Escaped ansi sequence
M.ansi = setmetatable({}, {
    ---@param t table
    ---@param k string
    ---@return string
    __index = function(t, k)
        local v = M.render_str("%s", k)
        rawset(t, k, v)
        return v
    end,
})

---Remove ANSI escape sequences from a string
---@param str string
---@return string, integer
M.remove_ansi = function(str)
    return str:gsub("\x1b%[[%d;]*%d[Km]", "")
end

---Return a 24 byte colored string
---@param color_num integer
---@param fg integer
---@return string
local function color2csi24b(color_num, fg)
    local r = math.floor(color_num / 2 ^ 16)
    local g = math.floor(math.floor(color_num / 2 ^ 8) % 2 ^ 8)
    local b = math.floor(color_num % 2 ^ 8)
    return ("%d;2;%d;%d;%d"):format(fg and 38 or 48, r, g, b)
end

local function color2csi8b(colorNum, fg)
    return ("%d;5;%d"):format(fg and 38 or 48, colorNum)
end

local ansi = {
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,
}

---Render an ANSI escape sequence
---@param str string
---@param group_name string
---@param default_fg string?
---@param default_bg string?
---@return string
function M.render_str(str, group_name, default_fg, default_bg)
    vim.validate({
        str = {str, "string"},
        group_name = {group_name, "string"},
        default_fg = {default_fg, "string", true},
        default_bg = {default_bg, "string", true},
    })
    local gui = vim.o.termguicolors
    local ok, hl = pcall(api.nvim_get_hl_by_name, group_name, gui)
    if not ok or
        not (hl.foreground or hl.background or hl.reverse or hl.bold or hl.italic or hl.underline) then
        return str
    end
    local fg, bg
    if hl.reverse then
        fg = hl.background ~= nil and hl.background or nil
        bg = hl.foreground ~= nil and hl.foreground or nil
    else
        fg = hl.foreground
        bg = hl.background
    end
    local escape_prefix = ("\027[%s%s%s"):format(
        hl.bold and ";1" or "",
        hl.italic and ";3" or "",
        hl.underline and ";4" or ""
    )

    local color_to_csi = gui and color2csi24b or color2csi8b
    local escape_fg, escape_bg = "", ""
    if fg and type(fg) == "number" then
        escape_fg = ";" .. color_to_csi(fg, true)
    elseif default_fg and ansi[default_fg] then
        escape_fg = tostring(ansi[default_fg])
    end
    if bg and type(bg) == "number" then
        escape_fg = ";" .. color_to_csi(bg, false)
    elseif default_bg and ansi[default_bg] then
        escape_fg = tostring(ansi[default_fg])
    end

    return ("%s%s%sm%s\027[m"):format(escape_prefix, escape_fg, escape_bg, str)
end

local ns = api.nvim_create_namespace("l-highlight")
local function do_unpack(pos)
    vim.validate({pos = {pos, {"t", "n"}, "must be table or number type"}})
    local row, col
    if type(pos) == "table" then
        row, col = unpack(pos)
    else
        row = pos
    end
    col = col or 0
    return row, col
end

---Wrapper to deal with extmarks
---@param bufnr integer
---@param hl_group string
---@param start table|integer
---@param finish table|number
---@param opt? table
---@param delay? integer
function M.highlight(bufnr, hl_group, start, finish, opt, delay)
    local row, col = do_unpack(start)
    local end_row, end_col = do_unpack(finish)
    if end_col then
        end_col = math.min(math.max(fn.col({end_row + 1, "$"}) - 1, 0), end_col)
    end
    local o = {hl_group = hl_group, end_row = end_row, end_col = end_col}
    o = opt and vim.tbl_deep_extend("keep", o, opt) or o
    local id = api.nvim_buf_set_extmark(bufnr, ns, row, col, o)

    vim.defer_fn(function()
        pcall(api.nvim_buf_del_extmark, bufnr, ns, id)
    end, delay or 300)
end

---Expand a tab in a string
---@param str string
---@param ts number
---@param start? number
---@return string
M.expandtab = function(str, ts, start)
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

---API around `nvim_echo`
---"Colored echo"
M.cecho =
    (function()
        local lastmsg
        local debounced
        ---Echo a colored message
        ---@param msg string message to echo
        ---@param hl string highlight group to link
        ---@param history? boolean add message to history
        ---@param wait? number amount of time to wait
        return function(msg, hl, history, wait)
            history = history or true
            vim.schedule(
                function()
                    api.nvim_echo({{msg, hl}}, history, {})
                    lastmsg = Rc.api.exec_output("5message", true)
                end
            )
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

---@class utils.StrQuoteSpec
---@field esc_fmt string Format string for escaping quotes. Passed to `string.format()`.
---@field prefer_single boolean Prefer single quotes.
---@field only_if_whitespace boolean Only quote the string if it contains whitespace.

---@param s string
---@param opt? utils.StrQuoteSpec
---@return string
function M.str_quote(s, opt)
    ---@cast opt utils.StrQuoteSpec
    s = tostring(s)
    opt = vim.tbl_extend("keep", opt or {}, {
        esc_fmt = [[\%s]],
        prefer_single = false,
        only_if_whitespace = false,
    }) --[[@as utils.StrQuoteSpec ]]

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

---Return a concatenated table as as string.
---Really only useful for setting options
---@param value table Table to concatenate
---@param sep? string Separator to concatenate the table
---@param str? string String to concatenate to the table
---@return string
function M.list(value, sep, str)
    sep = sep or ","
    str = str or ""
    value = F.if_expr(type(value) == "table", table.concat(value, sep), value)
    return F.if_expr(str ~= "", table.concat({value, str}, sep), value)
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

---Clear the command line prompt
function M.clear_prompt()
    -- api.nvim_echo({{""}}, false, {})
    api.nvim_echo({}, false, {})
    cmd.redraw()
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---@class InputCharSpec
---@field clear_prompt boolean (default: true)
---@field allow_non_ascii boolean (default: false)
---@field filter string A lua pattern that the input must match in order to be valid. (default: nil)
---@field loop boolean Loop the input prompt until a valid char is given. (default: false)
---@field prompt_hl string (default: nil)

---@param prompt string
---@param opt InputCharSpec
---@return string? Char
---@return string|number Raw
function M.input_char(prompt, opt)
    opt = vim.tbl_extend("keep", opt or {}, {
        clear_prompt = true,
        allow_non_ascii = false,
        loop = false,
        prompt_hl = nil,
    }) --[[@as InputCharSpec]]

    local valid, s, raw
    while true do
        valid = true

        if prompt then
            api.nvim_echo({{prompt, opt.prompt_hl}}, false, {})
        end

        local c
        if not opt.allow_non_ascii then
            while type(c) ~= "number" do
                c = fn.getchar()
            end
        else
            c = fn.getchar()
        end

        if opt.clear_prompt then
            M.clear_prompt()
        end

        s = type(c) == "number" and fn.nr2char(c) or nil
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

---@class InputSpec
---@field default string
---@field completion string|function
---@field cancelreturn string
---@field callback fun(response: string?)

---@param prompt string
---@param opt InputSpec
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

---@class utils.confirm.Opt
---@field default boolean
---@field callback fun(choice: boolean)

---@param prompt string
---@param opt utils.confirm.Opt
function M.confirm(prompt, opt)
    local ok, s = pcall(
        M.input_char,
        ("%s %s: "):format(
            prompt,
            opt.default and "[Y/n]" or "[y/N]"
        ),
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

---Create a temporary scratch buffer
---@param opts vim.bo
---@return bufnr
function M.create_sratch_buf(opts)
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

return M
