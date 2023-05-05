---@description: Utility functions that are used in multiple files
---@module "common.utils.funcs"
---@class UtilFuncs
local M = {}

local log = require("common.log")
local debounce = require("common.debounce")
local style = require("style")
local lazy = require("common.lazy")
local mpi = lazy.require_on_exported_call("common.api")
local W = require("common.api.win")

-- local uva = require("uva")
-- local async = require("async")
-- local uv = vim.loop

local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local F = vim.F

---Execute a command in normal mode. Equivalent to `norm! <cmd>`
---@param mode FeedkeysMode|FeedkeysMode[]
---@param motion string
M.normal = function(mode, motion)
    mode = type(mode) == "table" and _t(mode):concat("") or mode
    api.nvim_feedkeys(M.termcodes[motion], mode, false)
end

---Wrapper to make getting the current mode easier
---@return string
M.mode = function()
    return api.nvim_get_mode().mode
end

---Program to check if executable
---@param exec string
---@return boolean?
M.executable = function(exec)
    vim.validate({exec = {exec, "string"}})
    -- return not M.is.empty(exec) and fn.executable(exec) == 1
    return fn.executable(exec) == 1
end

---Get the output of a system command in a table
---@param cmd string|table
---@return Vector<string>
M.get_system_output = function(cmd)
    return vim.split(fn.system(cmd), "\n")
end

-- Replace termcodes; e.g., t'<C-n>'
---@param str string: String to be converted
---@param from_part? boolean: Legacy vim parameter. Usually true
---@param do_lt? boolean: Also translate `<lt>` (Ignored if special is false)
---@param special? boolean: Replace keycodes, e.g., `<CR>` => `\r`
---@return string
M.t = function(str, from_part, do_lt, special)
    ---@diagnostic disable-next-line:return-type-mismatch
    return api.nvim_replace_termcodes(
        str,
        F.if_nil(from_part, true),
        F.if_nil(do_lt, true),
        F.if_nil(special, true)
    )
end

---Check whether or not the location or quickfix list is open
---@return boolean
M.is_vim_list_open = function()
    for _, win in ipairs(api.nvim_list_wins()) do
        local buf = api.nvim_win_get_buf(win)
        local location_list = fn.getloclist(0, {filewinid = 0})
        ---@diagnostic disable-next-line:undefined-field
        local is_loc_list = location_list.filewinid > 0
        if vim.bo[buf].filetype == "qf" or is_loc_list then
            return true
        end
    end
    return false
end

--  ══════════════════════════════════════════════════════════════════════

do
    local notifications = {}

    ---Wrapper to send a notification
    ---@param msg string Message to notify
    ---@param level number
    ---@param opts? NotifyOpts
    M.notify = function(msg, level, opts)
        level = F.if_nil(level, log.levels.INFO)
        local keep = function()
            return true
        end

        local _opts =
            ({
                [log.levels.TRACE] = {timeout = 500},
                [log.levels.DEBUG] = {timeout = 1000},
                [log.levels.INFO] = {timeout = 1000},
                [log.levels.WARN] = {timeout = 3000},
                [log.levels.ERROR] = {timeout = 5000, keep = keep},
            })[level]

        opts = vim.tbl_extend("force", _opts or {}, opts or {}) --[[@as NotifyOpts]]

        if opts.style and not opts.render then
            opts.render = opts.style
            opts.style = nil
        end

        local function notify()
            if vim.g.nvim_focused then
                -- return vim.notify(msg, level, opts)
                local ok, notify = pcall(require, "notify")
                if not ok then
                    vim.defer_fn(
                        function()
                            vim.notify(msg, level, opts)
                        end,
                        100
                    )
                    return
                end
                return notify.notify(msg, level, opts)
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
_G.N =
    setmetatable(
        {},
        {
            __index = function(super, level)
                level = M.unwrap_or(rawget(super, level), level)

                return setmetatable(
                    {},
                    {
                        ---@param _ self
                        ---@param msg string
                        ---@param title? string
                        __call = function(_, msg, title)
                            super(msg, title, level)
                        end,
                    }
                )
            end,
            ---@param _ self
            ---@param msg string
            ---@param title? string
            ---@param level? string|number
            __call = function(_, msg, title, level)
                level =
                    ({
                        ["trace"] = 0,
                        ["debug"] = 1,
                        ["info"] = 2,
                        ["warn"] = 3,
                        ["error"] = 4,
                        ["err"] = 4,
                    })[level] or level

                log.dump(msg, {title = title, level = level, thread = 3})
            end,
        }
    )

--  ══════════════════════════════════════════════════════════════════════

---Preserve cursor position when executing command
M.preserve = function(arguments)
    local view = W.win_save_positions(0)
    local arguments = ("%q"):format(arguments)
    local line, col = unpack(api.nvim_win_get_cursor(0))
    cmd(("keepj keepp execute %s"):format(arguments))
    local lastline = fn.line("$")
    if line > lastline then
        line = lastline
    end

    mpi.set_cursor(0, line, col)
    view.restore()
end

---Preserve cursor position and marks when executing a subsitute command
M.preserve_sub = function(args)
    M.preserve(("sil! keepp keepj %s"):format(args))
end

---Remove duplicate blank lines (2 -> 1)
M.squeeze_blank_lines = function()
    if vim.bo.binary == false and vim.o.ft ~= "diff" then
        local old_query = nvim.reg["/"]
        M.preserve_sub("sil! keepp keepj 1,.s/^\\n\\{2,}/\\r/gn") -- set current search count number
        local result = fn.searchcount({maxcount = 1000, timeout = 500}).current
        local line, col = unpack(api.nvim_win_get_cursor(0))
        M.preserve_sub("%s/^\\n\\{2,}/\\r/ge")
        M.preserve_sub("%s/\\v($\\n\\s*)+%$/\\r/e")
        M.preserve_sub([[0;/^\%(\n*.\)\@!/,$d]])
        if result > 0 then
            mpi.set_cursor(0, (line - result), col)
        end
        nvim.reg["/"] = old_query
    end
end

M.perf = function(msg, func, ...)
    local start = os.clock()
    local data = func(...)
    msg = msg or "Elapsed time:"
    p(msg, ("%.5f s"):format(os.clock() - start))
    return data
end

--  ══════════════════════════════════════════════════════════════════════

---Table of escaped termcodes
M.termcodes =
    setmetatable(
        {},
        {
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
        }
    )

---Escaped ansi sequence
M.ansi =
    setmetatable(
        {},
        {
            ---@param t table
            ---@param k string
            ---@return string
            __index = function(t, k)
                local v = M.render_str("%s", k)
                rawset(t, k, v)
                return v
            end,
        }
    )

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

---Return a 8 byte colored string
---@param color_num integer
---@param fg integer
---@return string
local function color2csi8b(color_num, fg)
    return ("%d;5;%d"):format(fg and 38 or 48, color_num)
end

M.render_str =
    (function()
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
        local gui = vim.o.termguicolors
        local color2csi = gui and color2csi24b or color2csi8b

        ---Render an ANSI escape sequence
        ---@param str string
        ---@param group_name string
        ---@param def_fg string?
        ---@param def_bg string?
        return function(str, group_name, def_fg, def_bg)
            vim.validate(
                {
                    str = {str, "string"},
                    group_name = {group_name, "string"},
                    def_fg = {def_fg, "string", true},
                    def_bg = {def_bg, "string", true},
                }
            )
            local ok, hl = pcall(api.nvim_get_hl_by_name, group_name, gui)
            if
                not ok or
                not (hl.foreground or hl.background or hl.reverse or hl.bold or hl.italic or
                    hl.underline)
            then
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
            local escape_prefix =
                ("\x1b[%s%s%s"):format(
                    hl.bold and ";1" or "",
                    hl.italic and ";3" or "",
                    hl.underline and ";4" or ""
                )

            local escape_fg, escape_bg = "", ""
            if fg and type(fg) == "number" then
                escape_fg = ";" .. color2csi(fg, true)
            elseif def_fg and ansi[def_fg] then
                ---@diagnostic disable-next-line:cast-local-type
                escape_fg = ansi[def_fg]
            end
            if bg and type(bg) == "number" then
                escape_fg = ";" .. color2csi(bg, false)
            elseif def_bg and ansi[def_bg] then
                ---@diagnostic disable-next-line:cast-local-type
                escape_fg = ansi[def_bg]
            end

            return ("%s%s%sm%s\x1b[m"):format(escape_prefix, escape_fg, escape_bg, str)
        end
    end)()

M.highlight =
    (function()
        local ns = api.nvim_create_namespace("l-highlight")
        local function do_unpack(pos)
            vim.validate(
                {
                    pos = {pos, {"t", "n"}, "must be table or number type"},
                }
            )
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
        ---@param start integer
        ---@param finish number
        ---@param opt? table
        ---@param delay integer
        return function(bufnr, hl_group, start, finish, opt, delay)
            local row, col = do_unpack(start)
            local end_row, end_col = do_unpack(finish)
            if end_col then
                end_col = math.min(math.max(fn.col({end_row + 1, "$"}) - 1, 0), end_col)
            end
            local o = {hl_group = hl_group, end_row = end_row, end_col = end_col}
            o = opt and vim.tbl_deep_extend("keep", o, opt) or o
            local id = api.nvim_buf_set_extmark(bufnr, ns, row, col, o)
            vim.defer_fn(
                function()
                    pcall(api.nvim_buf_del_extmark, bufnr, ns, id)
                end,
                delay or 300
            )
        end
    end)()

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
        ---@param history boolean? add message to history
        ---@param wait number? amount of time to wait
        return function(msg, hl, history, wait)
            history = F.if_nil(history, true) --[[@as boolean]]
            vim.schedule(
                function()
                    api.nvim_echo({{msg, hl}}, history, {})
                    lastmsg = api.nvim_exec("5message", true)
                end
            )
            if not debounced then
                debounced =
                    debounce(
                        function()
                            if lastmsg == api.nvim_exec("5message", true) then
                                api.nvim_echo({{"", ""}}, false, {})
                            end
                        end,
                        wait or 2500
                    )
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
M.lambda = function(str)
    if not lambda_cache[str] then
        local args, body = str:match([[^([%w,_ ]-)%->(.-)$]])
        assert(args and body, "bad string lambda")
        local s = "return function(" .. args .. ")\nreturn " .. body .. "\nend"
        lambda_cache[str] = M.dostring(s)
    end
    return lambda_cache[str]
end

---Load or `loadstring`
---@param str string
---@return fun(s: string): any
M.dostring = function(str)
    return assert((loadstring or load)(str))()
end

---Simple string templating
---Example template: "${name} is ${value}"
---@param str string Template string
---@param table table Key-value pairs to replace in the string
---@return string
M.str_template = function(str, table)
    return (str:gsub(
        "($%b{})",
        function(w)
            return table[w:sub(3, -2)] or w
        end
    ))
end

---Return a concatenated table as as string.
---Really only useful for setting options
---
---@param value table: Table to concatenate
---@param sep? string: Separator to concatenate the table
---@param str? string: String to concatenate to the table
---@return string
M.list = function(value, sep, str)
    sep = sep or ","
    str = str or ""
    value = F.if_expr(type(value) == "table", table.concat(value, sep), value)
    return F.if_expr(str ~= "", table.concat({value, str}, sep), value)
end

---@param str string
---@param max_len integer
---@return string
M.truncate = function(str, max_len)
    vim.validate{
        str = {str, "s", false},
        max_len = {max_len, "n", false},
    }

    return F.if_expr(
        api.nvim_strwidth(str) > max_len,
        str:sub(1, max_len) .. style.icons.misc.ellipsis,
        str
    )
end

---Print a value in lua
---@generic T : any
---@param v T Value to inspect
---@return T
M.inspect = function(v)
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

return M
