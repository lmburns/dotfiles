--- Tools that will help with Lua development

local M = {}

local log = require("common.log")
local Path = require("plenary.path")

local fn = vim.fn
local api = vim.api
local uv = vim.loop

---@alias vector table

-- Addition to `os` module
---Capture output of command as a string
function os.capture(cmd, raw)
    local f = assert(io.popen(cmd, "r"))
    local s = assert(f:read("*a"))
    f:close()
    if raw then
        return s
    end
    s = string.gsub(s, "^%s+", "")
    s = string.gsub(s, "%s+$", "")
    s = string.gsub(s, "[\n\r]+", " ")
    return s
end

-- ╒══════════════════════════════════════════════════════════╕
--                            Global
-- ╘══════════════════════════════════════════════════════════╛

_G.pln = function(...)
    local argc = select("#", ...)
    local msg_tbl = {}
    for i = 1, argc do
        local arg = select(i, ...)
        table.insert(msg_tbl, M.inspect(arg))
    end

    print(table.concat(msg_tbl, "\n\n"))
end

---Print text nicely
_G.p = function(...)
    local argc = select("#", ...)
    local msg_tbl = {}
    for i = 1, argc do
        local arg = select(i, ...)
        table.insert(msg_tbl, M.inspect(arg))
    end

    print(table.concat(msg_tbl, " "))
end

_G.pp = vim.pretty_print

-- ╒══════════════════════════════════════════════════════════╕
--                      Development tools
-- ╘══════════════════════════════════════════════════════════╛

---Use in combination with pcall
---@param status boolean
---@param ... any
---@return any
M.ok_or_nil = function(status, ...)
    if not status then
        local args = {...}
        local msg = vim.split(table.concat(args, "\n"), "\n")
        local mod = msg[1]:match("module '(%w.*)'")
        log.err(msg, true, {title = ('Failed to require("%s")'):format(mod)})
        return
    end
    return ...
end

---Nil `pcall`.
---If `pcall` succeeds, return result of `fn`, else `nil`
---@param fn fun(args: ...)
---@param ... any
---@return any
M.npcall = function(fn, ...)
    return M.ok_or_nil(pcall(fn, ...))
end

---Wrap a function to return `nil` if it fails, otherwise the value
---@param fn fun(args: ...)
---@return fun(args: ...)
M.nil_wrap = function(fn)
    return function(...)
        return M.npcall(fn, ...)
    end
end

---Bind a function to some arguments and return a new function (the thunk) that can be called later
---Useful for setting up callbacks without anonymous functions
---
--- ### Example 1: Only string
---```lua
--- map("n", "yd", ":lua require('common.yank').yank_reg(vim.v.register, vim.fn.expand('%:p:h'))<CR>")
---```
---
--- ### Example 2: Anonymous functions
---```lua
--- map(
---     "n",
---     "yd",
---     function()
---         require("common.yank").yank_reg(vim.v.register, fn.expand("%:p:h"))
---     end
--- )
---```
---
--- ### Example 3: Thunk
---```lua
---  map("n", "yd", dev.ithunk(require("common.yank").yank_reg, vim.v.register, fn.expand("%:p:h")))
---```
M.thunk = function(fun, ...)
    local bound = {...}
    return function(...)
        return fun(unpack(vim.list_extend(vim.list_extend({}, bound), {...})))
    end
end

---Like thunk(), but arguments passed to the thunk are ignored
M.ithunk = function(fun, ...)
    local bound = {...}
    return function()
        return fun(unpack(bound))
    end
end

---Get the output of a system command in a table
---@param cmd string|table
---@return table
M.get_system_output = function(cmd)
    return vim.split(fn.system(cmd), "\n")
end

---Get the output of a vim command in a table
---@param cmd string|table
---@return table
M.get_vim_output = function(cmd)
    local out = api.nvim_exec(cmd, true)
    local res = vim.split(out, "\n", {trimempty = true})
    return M.map(
        res,
        function(val)
            return vim.trim(val)
        end
    )
end

---@class JobOpts
---@field on_stdout function function to run on stdout
---@field input string input for stdin
---@field on_exit function function to run on exit

---@param cmd string
---@param opts JobOpts
---@return number the job id
M.start_job = function(cmd, opts)
    opts = opts or {}
    local id =
        fn.jobstart(
        cmd,
        {
            stdout_buffered = true,
            on_stdout = function(_, data, _)
                if data and type(opts.on_stdout) == "function" then
                    opts.on_stdout(data)
                end
            end,
            on_exit = function(_, data, _)
                if type(opts.on_exit) == "function" then
                    opts.on_exit(data)
                end
            end
        }
    )

    if opts.input then
        api.nvim_chan_send(id, opts.input)
        -- fn.chansend(id, opts.input)
        fn.chanclose(id, "stdin")
    end

    return id
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Print                           │
-- ╰──────────────────────────────────────────────────────────╯

---Print a value in lua
M.inspect = function(v)
    local s
    local t = type(v)
    if t == "nil" then
        s = "nil"
    elseif t == "userdata" then
        s = ("Userdata:\n%s"):format(vim.inspect(getmetatable(v)))
    elseif t ~= "string" then
        s = vim.inspect(v, {depth = math.huge})
    else
        s = tostring(v)
    end
    return s
end

M.round = function(value)
    return math.floor(value + 0.5)
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          String                          │
-- ╰──────────────────────────────────────────────────────────╯

---Split a string on a delimiter
---@param input string
---@param sep string
---@return string
M.split = function(input, sep)
    vim.validate {
        input = {input, {"s"}},
        sep = {sep, {"s"}}
    }
    local t = {}
    for str in string.gmatch(input, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

---Check if `string` is empty or `nil`
---@return boolean
M.is_empty = function(str)
    return str == "" or str == nil
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Table                           │
-- ╰──────────────────────────────────────────────────────────╯

---Create table whose keys are now the values, and the values are now the keys
---Similar to vim.tbl_add_reverse_lookup
---
---Assumes that the values in tbl are unique and hashable (no nil/NaN)
---@generic K,V
---@param tbl table<K,V>
---@return table<V,K>
M.tbl_reverse_kv = function(tbl)
    local ret = {}
    for k, v in pairs(tbl) do
        ret[v] = k
    end
    return ret
end

---Determine whether two tables are equivalent
---@param t1 table
---@param t2 table
---@param ignore_mt boolean Ignore metatable
---@return boolean
M.tbl_equivalent = function(t1, t2, ignore_mt)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then
        return false
    end
    if ty1 ~= "table" and ty2 ~= "table" then
        return t1 == t2
    end

    local mt = getmetatable(t1)
    if not ignore_mt and mt and mt.__eq then
        return t1 == t2
    end
    for k1, v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not M.tbl_equivalent(v1, v2) then
            return false
        end
    end
    for k2, v2 in pairs(t2) do
        local v1 = t1[k2]
        if v1 == nil or not M.tbl_equivalent(v1, v2) then
            return false
        end
    end
    return true
end

---Merge two tables
---@param a 'table'
---@param b 'table'
---@return 'table'
M.merge = function(a, b)
    if type(a) == "table" and type(b) == "table" then
        for k, v in pairs(b) do
            if type(v) == "table" and type(a[k] or false) == "table" then
                M.merge(a[k], v)
            else
                a[k] = v
            end
        end
    end
    return a
end

---Return a table with duplicates filtered out
---@param array table
---@return table
M.filter_duplicates = function(array)
    local seen = {}
    local res = {}

    for _, v in ipairs(array) do
        if not seen[v] then
            res[#res + 1] = v
            seen[v] = true
        end
    end
    return res
end

---Execute a function across a table, keeping an accumulation of results
---@param tbl table
---@param fn fun(table, any, any)
---@param acc table
---@return table
M.tbl_reduce = function(tbl, func, acc)
    for k, v in pairs(tbl) do
        acc = func(acc, v, k)
    end
    return acc
end

---Pack a table. Similar to `table.pack`. Sets number of elements to `.n`
---@vararg any any number of items to pack
---@return table
M.tbl_pack = function(...)
    return {n = select("#", ...), ...}
end

---Unpack a table into arguments. Similar to `table.unpack`
---@param t table table to unpack
---@param i number
---@param j number
---@return any
M.tbl_unpack = function(t, i, j)
    return unpack(t, i or 1, j or t.n or #t)
end

---Clear a table's values
---@param t table
M.tbl_clear = function(t)
    for k, _ in pairs(t) do
        t[k] = nil
    end
end

---Clone a table
---
---@param t table: Table to clone
---@return table
M.tbl_clone = function(t)
    if not t then
        return
    end
    local clone = {}

    for k, v in pairs(t) do
        clone[k] = v
    end

    return clone
end

---Deep clone a table (i.e., clone nested tables)
---@param t table
---@return table
M.tbl_deep_clone = function(t)
    if not t then
        return
    end
    local clone = {}

    for k, v in pairs(t) do
        if type(v) == "table" then
            clone[k] = M.tbl_deep_clone(v)
        else
            clone[k] = v
        end
    end

    return clone
end

---Create a shallow copy of a portion of a vector.
---@param t vector
---@param first? integer First index, inclusive
---@param last? integer Last index, inclusive
---@return vector
M.vec_slice = function(t, first, last)
    local slice = {}
    for i = first or 1, last or #t do
        table.insert(slice, t[i])
    end

    return slice
end

---Join multiple vectors into one.
---@vararg vector
---@return vector
M.vec_join = function(...)
    local result = {}
    local args = {...}
    local n = 0

    for i = 1, select("#", ...) do
        if type(args[i]) ~= "nil" then
            if type(args[i]) ~= "table" then
                result[n + 1] = args[i]
                n = n + 1
            else
                for j, v in ipairs(args[i]) do
                    result[n + j] = v
                end
                n = n + #args[i]
            end
        end
    end

    return result
end

---Find an item in a list
---@generic T
---@param haystack T[]
---@param matcher fun(arg: T):boolean
---@return T
M.find = function(haystack, matcher)
    local found
    for _, needle in ipairs(haystack) do
        if matcher(needle) then
            found = needle
            break
        end
    end
    return found
end

---Search for a value in a table
---@param tbl table Table/List to search through
---@param val any Value to find
---@return boolean
M.has_value = function(tbl, val)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end

    return false
end

---Get the result of the union of the given vectors.
---@vararg vector
---@return vector
M.vec_union = function(...)
    local result = {}
    local args = {...}
    local seen = {}

    for i = 1, select("#", ...) do
        if type(args[i]) ~= "nil" then
            if type(args[i]) ~= "table" and not seen[args[i]] then
                seen[args[i]] = true
                result[#result + 1] = args[i]
            else
                for _, v in ipairs(args[i]) do
                    if not seen[v] then
                        seen[v] = true
                        result[#result + 1] = v
                    end
                end
            end
        end
    end

    return result
end

---Get the result of the difference of the given vectors.
---@vararg vector
---@return vector
M.vec_diff = function(...)
    local args = {...}
    local seen = {}

    for i = 1, select("#", ...) do
        if type(args[i]) ~= "nil" then
            if type(args[i]) ~= "table" then
                if i == 1 then
                    seen[args[i]] = true
                elseif seen[args[i]] then
                    seen[args[i]] = nil
                end
            else
                for _, v in ipairs(args[i]) do
                    if i == 1 then
                        seen[v] = true
                    elseif seen[v] then
                        seen[v] = nil
                    end
                end
            end
        end
    end

    return vim.tbl_keys(seen)
end

---Get the result of the symmetric difference of the given vectors.
---@vararg vector
---@return vector
M.vec_symdiff = function(...)
    local result = {}
    local args = {...}
    local seen = {}

    for i = 1, select("#", ...) do
        if type(args[i]) ~= "nil" then
            if type(args[i]) ~= "table" then
                seen[args[i]] = seen[args[i]] == 1 and 0 or 1
            else
                for _, v in ipairs(args[i]) do
                    seen[v] = seen[v] == 1 and 0 or 1
                end
            end
        end
    end

    for v, state in pairs(seen) do
        if state == 1 then
            result[#result + 1] = v
        end
    end

    return result
end

---Return the first index a given object can be found in a vector, or -1 if
---it's not present.
---
---@param t vector
---@param v any
---@return integer
M.vec_indexof = function(t, v)
    for i, vt in ipairs(t) do
        if vt == v then
            return i
        end
    end
    return -1
end

---Append any number of objects to the end of a vector.
---Pushing `nil` effectively does nothing.
---
---@param t vector
---@return vector t
M.vec_push = function(t, ...)
    for _, v in ipairs({...}) do
        t[#t + 1] = v
    end
    return t
end

---Checks if a list-like (vector) table contains `value`.
---
---@param t vector Table to check
---@param value any Value to compare
---@returns boolean true if `t` contains `value`
M.contains = function(t, value)
    return vim.tbl_contains(t, value)
end

---Apply a function to each value in a table.
---@param tbl table
---@param func function (value)
M.map = function(tbl, func)
    -- local t = {}
    -- for k, v in pairs(tbl) do
    --     t[k] = func(v)
    -- end
    -- return t
    return vim.tbl_map(func, tbl)
end

---Filter table based on function
---@param tbl table Table to be filtered
---@param func function Function to apply filter
---@return table
M.filter = function(tbl, func)
    return vim.tbl_filter(func, tbl)
end

---Apply function to each element of vector
---@param tbl vector A list of elements
---@param func fun(v: any) to be applied
M.each = function(tbl, func)
    for _, item in ipairs(tbl) do
        func(item)
    end
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                         Buffers                          │
-- ╰──────────────────────────────────────────────────────────╯

---Determine whether the buffer is empty
---@param bufnr number
---@return boolean
M.buf_is_empty = function(bufnr)
    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    return #lines == 1 and lines[1] == ""
end

---`vim.api.nvim_is_buf_loaded` filters out all hidden buffers
M.buf_is_valid = function(bufnr)
    if not bufnr or bufnr < 1 then
        return false
    end
    local exists = api.nvim_buf_is_valid(bufnr)
    return vim.bo[bufnr].buflisted and exists
end

---Check whether the current buffer is modified
---@param bufnr number?
---@return boolean
M.buf_is_modified = function(bufnr)
    vim.validate {
        buffer = {
            bufnr,
            function(b)
                return (type(b) == "number" and b > 1) or type(b) == "nil"
            end
        }
    }

    bufnr = bufnr or api.nvim_get_current_buf()
    return vim.bo[bufnr].modified
end

---Get the number of buffers
---@return number
M.get_buf_count = function()
    return #fn.getbufinfo({buflisted = 1})
end

---Get valid buffers
---@return number[]
M.get_valid_buffers = function()
    return M.filter(api.nvim_list_bufs(), M.buf_is_valid)
end

---Return a table of the id's of loaded buffers (hidden are removed)
---@return table
M.get_loaded_bufs = function()
    return M.filter(
        api.nvim_list_bufs(),
        function(id)
            return api.nvim_buf_is_loaded(id)
        end
    )
end

---@class ListBufsSpec
---@field loaded boolean Filter out buffers that aren't loaded.
---@field listed boolean Filter out buffers that aren't listed.
---@field no_hidden boolean Filter out buffers that are hidden.
---@field tabpage integer Filter out buffers that are not displayed in a given tabpage.

---@param opt? ListBufsSpec
M.list_bufs = function(opt)
    -- vim.validate {
    --     loaded = {opt.loaded, {"b"}, true},
    --     listed = {opt.listed, {"b"}, true},
    --     no_hidden = {opt.listed, {"b"}, true},
    --     tabpage = {opt.listed, {"n"}, true}
    -- }
    opt = opt or {}
    local bufs

    if opt.no_hidden or opt.tabpage then
        local wins = opt.tabpage and api.nvim_tabpage_list_wins(opt.tabpage) or api.nvim_list_wins()
        local bufnr
        local seen = {}
        bufs = {}
        for _, winid in ipairs(wins) do
            bufnr = api.nvim_win_get_buf(winid)
            if not seen[bufnr] then
                table.insert(bufs, bufnr)
            end
            seen[bufnr] = true
        end
    else
        bufs = api.nvim_list_bufs()
    end

    return M.filter(
        bufs,
        function(v)
            if opt.loaded and not api.nvim_buf_is_loaded(v) then
                return false
            end
            if opt.listed and not vim.bo[v].buflisted then
                return false
            end
            return true
        end
    )
end

---Find a buffer that has a given variable with a value
---@param var string variable to search for
---@param value string|number value the variable should have
---@param opts? ListBufsSpec
---@return any
M.find_buf_with_var = function(var, value, opts)
    for _, id in ipairs(M.list_bufs(opts or {})) do
        local ok, v = pcall(api.nvim_buf_get_var, id, var)
        if ok and v == value then
            return id
        end
    end

    return nil
end

---Find a buffer that has an option set at a value
---@param option string option to search for
---@param value string|number value the option should have
---@param opts? ListBufsSpec
---@return any
M.find_buf_with_option = function(option, value, opts)
    for _, id in ipairs(opts or {}) do
        local ok, v = pcall(api.nvim_buf_get_option, id, option)
        if ok and v == value then
            return id
        end
    end

    return nil
end

---Find a buffer whose full path matches a pattern
---@param pattern string Lua pattern mathed against buffer name
---@param opt? ListBufsSpec
---@return integer?
M.find_buf_with_pattern = function(pattern, opt)
    for _, id in ipairs(M.list_bufs(opt or {})) do
        -- local m = fn.bufname(id):match(pattern)
        local m = api.nvim_buf_get_name(id):match(pattern)
        if m then
            return id
        end
    end

    return nil
end

---Fina a buffer that has a given name
---@param name string
---@param opt? ListBufsSpec
M.find_named_buffer = function(name, opt)
    for _, v in ipairs(M.list_bufs(opt or {})) do
        if fn.bufname(v) == name then
            return v
        end
    end
    return nil
end

---@param path string
---@param opt? ListBufsSpec
---@return integer? bufnr
M.find_file_buffer = function(path, opt)
    local p = Path:new(path):absolute()
    for _, id in ipairs(M.list_bufs(opt or {})) do
        if p == api.nvim_buf_get_name(id) then
            return id
        end
    end
end

---Return the buffer lines
---@param bufnr number?
---@return string
M.buf_lines = function(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    local buftext = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    if vim.bo[bufnr].ff == "dos" then
        for i = 1, #buftext do
            buftext[i] = buftext[i] .. "\r"
        end
    end
    return buftext
end

---Check if the buffer name matches a terminal buffer name
---@param bufname string
---@return boolean
M.is_term_bufname = function(bufname)
    if bufname and bufname:match("term://") then
        return true
    end
    return false
end

---Check if the given buffer is a terminal buffer
---@param bufnr number?
---@return boolean
M.is_term_buffer = function(bufnr)
    bufnr = tonumber(bufnr) or 0
    bufnr = bufnr == 0 and api.nvim_get_current_buf() or bufnr
    local winid = fn.bufwinid(bufnr)
    if tonumber(winid) > 0 and api.nvim_win_is_valid(winid) then
        return fn.getwininfo(winid)[1].terminal == 1
    end
    local bufname = M.buf_is_valid(bufnr) and api.nvim_buf_get_name(bufnr)
    return M.is_term_bufname(bufname)
end

---Get the nubmer of tabs
---@return number
M.get_tab_count = function()
    return #fn.gettabinfo()
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Window                          │
-- ╰──────────────────────────────────────────────────────────╯

---Determine if the window is the only open one
---@param win_id number?
---@return boolean
M.is_last_win = function(win_id)
    win_id = win_id or api.nvim_get_current_win()
    local n = 0
    for _, tab in ipairs(api.nvim_list_tabpages()) do
        for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
            if win_id == win then
                n = n + 1
            end
            if n > 1 then
                return false
            end
        end
    end
    return true
end

---Determine whether the window is floating
---@param winid number
---@return boolean
M.is_floating_window = function(winid)
    return api.nvim_win_get_config(winid).relative ~= ""
    --
    -- This two commands here are not equivalent as the docs might suggest
    -- In the function below `M.find_win_except_float`,
    -- they act the same about 200ms into starting Neovim
    --
    -- return fn.win_gettype() == 'popup'
end

---Find a window that is not floating
---@param bufnr number
---@return number
M.find_win_except_float = function(bufnr)
    local winid = fn.bufwinid(bufnr)
    if fn.win_gettype(winid) == "popup" then
        local f_winid = winid
        winid = 0
        for _, wid in ipairs(api.nvim_list_wins()) do
            if f_winid ~= wid and api.nvim_win_get_buf(wid) == bufnr then
                winid = wid
                break
            end
        end
    end
    return winid
end

---Get windows of a given type
---@param wintype string
---@return table
M.get_wins_of_type = function(wintype)
    return M.filter(
        api.nvim_list_wins(),
        function(winid)
            return fn.win_gettype(winid) == wintype
        end
    )
end

---Return a table of window ID's for quickfix windows
---@return table<number, boolean>
M.get_qfwin = function()
    return M.get_wins_of_type("quickfix")[1]
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Reload                          │
-- ╰──────────────────────────────────────────────────────────╯
---Reload all lua modules
---FIX: This fails in treesitter, where a module is loaded inside another module
M.reload_config = function()
    -- Handle impatient.nvim automatically.
    local luacache = (_G.__luacache or {}).modpaths.cache

    -- local lua_dirs = fn.glob(("%s/lua/*"):format(fn.stdpath("config")), 0, 1)
    -- require("plenary.reload").reload_module(dir)

    for name, _ in pairs(package.loaded) do
        if name:match("^plugs.") then
            package.loaded[name] = nil

            if luacache then
                luacache[name] = nil
            end
        end
    end

    dofile(env.NVIMRC)
    require("plugins").compile()
end

---Reload lua modules in a given path and reload the module
---@param path string
---@param recursive string
M.rreload_module = function(path, recursive)
    if recursive then
        for key, value in pairs(package.loaded) do
            if key ~= "_G" and value and fn.match(key, path) ~= -1 then
                package.loaded[key] = nil
                require(key)
            end
        end
    else
        package.loaded[path] = nil
        require(path)
    end
end

---NOTE: this plugin returns the currently loaded state of a plugin given
---given certain assumptions i.e. it will only be true if the plugin has been
---loaded e.g. lazy loading will return false
---@param plugin_name string
---@return boolean?
M.plugin_loaded = function(plugin_name)
    local plugins = _G.packer_plugins or {}
    return plugins[plugin_name] and plugins[plugin_name].loaded
end

local installed
---Check if a plugin is on the system not whether or not it is loaded
---@param plugin_name string
---@return boolean
M.plugin_installed = function(plugin_name)
    if not installed then
        local dirs = fn.expand(fn.stdpath("data") .. "/site/pack/packer/start/*", true, true)
        local opt = fn.expand(fn.stdpath("data") .. "/site/pack/packer/opt/*", true, true)
        vim.list_extend(dirs, opt)
        installed =
            vim.tbl_map(
            function(path)
                return fn.fnamemodify(path, ":t")
            end,
            dirs
        )
    end
    return vim.tbl_contains(installed, plugin_name)
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                           List                           │
-- ╰──────────────────────────────────────────────────────────╯
---Return a concatenated table as as string.
---Really only useful for setting options
---
---@param value table: Table to concatenate
---@param str string: String to concatenate to the table
---@param sep string: Separator to concatenate the table
---@return string
M.list = function(value, str, sep)
    sep = sep or ","
    str = str or ""
    value = type(value) == "table" and table.concat(value, sep) or value
    return str ~= "" and table.concat({value, str}, sep) or value
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       Switch-case                        │
-- ╰──────────────────────────────────────────────────────────╯

---Switch/case statement
---
---Usage:
--- <code>
--- a = switch {
---   [1] = function (x) print(x,10) end,
---   [2] = function (x) print(x,20) end,
---   default = function (x) print(x,0) end,
--- }
---
--- a:case(2)  -- ie. call case 2
--- a:case(9)
--- </code>
---
---@param t table: Table gets `:case` added
---@return table
-- function M.switch(t)
--     t.case = function(self, x)
--         local f = self[x] or self.default
--         if f then
--             if type(f) == "function" then
--                 f(x, self)
--             else
--                 error("case " .. tostring(x) .. " not a function")
--             end
--         end
--     end
--     return t
-- end

---Switch/case statement. Allows return statement
---
---Usage:
---<code>
--- c = 1
--- switch(c) : caseof {
---     [1]   = function (x) print(x,"one") end,
---     [2]   = function (x) print(x,"two") end,
---     [3]   = 12345, -- this is an invalid case stmt
---   default = function (x) print(x,"default") end,
---   missing = function (x) print(x,"missing") end,
--- }
---
--- -- also test the return value
--- -- sort of like the way C's ternary "?" is often used
--- -- but perhaps more like LISP's "cond"
--- --
--- print("expect to see 468:  ".. 123 +
---   switch(2):caseof{
---     [1] = function(x) return 234 end,
---     [2] = function(x) return 345 end
---   })
---</code>
---@param c table
---@return table
M.switch = function(c)
    local swtbl = {
        casevar = c,
        caseof = function(self, code)
            local f
            if (self.casevar) then
                f = code[self.casevar] or code.default
            else
                f = code.missing or code.default
            end
            if f then
                if type(f) == "function" then
                    return f(self.casevar, self)
                else
                    error("case " .. tostring(self.casevar) .. " not a function")
                end
            end
        end
    }
    return swtbl
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Async                           │
-- ╰──────────────────────────────────────────────────────────╯
M.set_timeout = function(callback, ms)
    local timer = uv.new_timer()
    timer:start(
        ms,
        0,
        function()
            timer:close()
            callback()
        end
    )
    return timer
end

-- Examples:  https://github.com/luvit/luv/tree/master/examples

return M
