--@module common.utils
---@description: Lowest level utility functions that will also be used in `common.utils`

local M = {}

local log = require("common.log")

local fn = vim.fn
local api = vim.api
local uv = vim.loop
local env = vim.env
local F = vim.F

---@class Vector<T>: { [integer]: T }
---@diagnostic disable-next-line:duplicate-doc-alias
---@alias module table

-- ╒══════════════════════════════════════════════════════════╕
--                            Global
-- ╘══════════════════════════════════════════════════════════╛

---Print text nicely, joined with newlines
_G.pln = function(...)
    local argc = select("#", ...)
    local msg_tbl = {}
    for i = 1, argc do
        local arg = select(i, ...)
        table.insert(msg_tbl, M.inspect(arg))
    end

    print(table.concat(msg_tbl, "\n\n"))
end

---Print text nicely, joined with spaces
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
---@return any?
M.ok_or_nil = function(status, ...)
    if not status then
        local args = {...}
        local info = debug.getinfo(1, "S")
        local msg = vim.split(table.concat(args, "\n"), "\n")
        local mod = msg[1]:match("module '(%w.*)'")
        log.err(msg, true, {title = ('Failed to require("%s"): %s'):format(mod, info)})
        return
    end
    return ...
end

---Nil `pcall`.
---If `pcall` succeeds, return result of `fn`, else `nil`
---@param fn fun(v: any)
---@param ... any
---@return any?
M.npcall = function(fn, ...)
    return M.ok_or_nil(pcall(fn, ...))
end

---Wrap a function to return `nil` if it fails, otherwise the value
---@param fn fun(v: any)
---@return fun(v: any)
M.nil_wrap = function(fn)
    return function(...)
        return M.npcall(fn, ...)
    end
end

---Bind a function to some arguments and return a new function (the thunk) that can be called later
---Useful for setting up callbacks without anonymous functions
---@generic T
---@param fn fun(v: T)
---@vararg T
---@return fun(v: T)
M.thunk = function(fn, ...)
    local bound = {...}
    return function(...)
        return fn(unpack(vim.list_extend(vim.list_extend({}, bound), {...})))
    end
end

---Like `thunk()`, but arguments passed to the thunk are ignored
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
---@generic T
---@param fn fun(v: T)
---@vararg T
---@return fun()
M.ithunk = function(fn, ...)
    local bound = {...}
    return function()
        return fn(unpack(bound))
    end
end

---Same as `ithunk()`, except prefixed with a `pcall`
---@generic T
---@param fn fun(v: T)
---@vararg T
---@return fun()
M.pithunk = function(fn, ...)
    return M.ithunk(pcall, fn, ...)
end

---Get the output of a system command in a table
---@param cmd string|table
---@return Vector<string>
M.get_system_output = function(cmd)
    return vim.split(fn.system(cmd), "\n")
end

---Get the output of a vim command in a *table*
---@param cmd string|table
---@return Vector<string>
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
---@generic T : any
---@param v T Value to inspect
---@return T
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

---If the value is less than min, return `min`
---If the value is greater than max, return `max`
---If the value is in-between min and max, return `value`
---@param value number
---@param min number
---@param max number
---@return number
M.clamp = function(value, min, max)
    if value < min then
        return min
    end
    if value > max then
        return max
    end
    return value
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Table                           │
-- ╰──────────────────────────────────────────────────────────╯

---Pack a table. Same as `table.pack`. Sets number of elements to `.n`
---@generic T
---@vararg T Any number of items to pack
---@return { n: number, [any]: T }
M.tbl_pack = function(...)
    return {n = select("#", ...), ...}
end

---Unpack a table into arguments. Same as `table.unpack`
---@param t table Table to unpack
---@param i number
---@param j number
---@return any
M.tbl_unpack = function(t, i, j)
    return unpack(t, i or 1, j or t.n or #t)
end

---Create table whose keys are now the values, and the values are now the keys
---Similar to `vim.tbl_add_reverse_lookup`
---
---Assumes that the values in tbl are unique and hashable (no `nil`)
---@generic K, V
---@param tbl table<K, V>
---@return table<V, K>
M.tbl_reverse_kv = function(tbl)
    local ret = {}
    for k, v in pairs(tbl) do
        ret[v] = k
    end
    return ret
end

---Determine whether two tables/vectors are equivalent
---@param t1 table|any[]
---@param t2 table|any[]
---@param ignore_mt boolean Ignore metatable
---@return boolean
M.tbl_equivalent = function(t1, t2, ignore_mt)
    -- vim.deep_equal(t1, t2)
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
---@param a table
---@param b table
---@return table
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

---Clear a table's values in-place
---@param t table
M.tbl_clear = function(t)
    for k, _ in pairs(t) do
        t[k] = nil
    end
end

---Clone a table
---@generic K, V
---@param t table<K, V>: Table to clone
---@return table<K, V>?
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
---@generic K, V
---@param t table<K, V>: Table to deep clone
---@return table<K, V>?
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

---Deep extend a table, while performing a union on all the sub-tables.
---@param t table<any>
---@param ... table<any>
---@return table<any>
M.tbl_union_extend = function(t, ...)
    local res = M.tbl_clone(t)

    local function recurse(ours, theirs)
        -- Get the union of the two tables
        local sub = M.vec_union(ours, theirs)

        for k, v in pairs(ours) do
            if type(k) ~= "number" then
                sub[k] = v
            end
        end

        for k, v in pairs(theirs) do
            if type(k) ~= "number" then
                if type(v) == "table" then
                    sub[k] = recurse(sub[k] or {}, v)
                else
                    sub[k] = v
                end
            end
        end

        return sub
    end

    for _, theirs in ipairs({...}) do
        res = recurse(res, theirs)
    end

    return res
end

---Perform a *map* and *filter* out index values that would become `nil`.
---@generic K, V
---@param t table<K, V>
---@param fn fun(v: V): any?
---@return table<K, V>
M.tbl_fmap = function(t, fn)
    local ret = {}

    for key, item in pairs(t) do
        local v = fn(item)
        if v ~= nil then
            if type(key) == "number" then
                table.insert(ret, v)
            else
                ret[key] = v
            end
        end
    end

    return ret
end

---Try property access into a table.
---@generic T : table
---@param t T Table to index into
---@param path string|string[]: Either a `.` separated string of table keys, or a list.
---@return T?
M.tbl_access = function(t, path)
    local keys = type(path) == "table" and path or vim.split(path, ".", {plain = true})

    local cur = t

    for _, k in ipairs(keys) do
        cur = cur[k]
        if not cur then
            return nil
        end
    end

    return cur
end

---Set a value in a table,
---creating all missing intermediate tables in the table path.
---@param t table Table to index into
---@param path string|string[]: Either a `.` separated string of table keys, or a list.
---@param value any
M.tbl_set = function(t, path, value)
    local keys = type(path) == "table" and path or vim.split(path, ".", {plain = true})

    local cur = t

    for i = 1, #keys - 1 do
        local k = keys[i]

        if not cur[k] then
            cur[k] = {}
        end

        cur = cur[k]
    end

    cur[keys[#keys]] = value
end

---Ensure that the table path is a valid in `t`.
---@param t table
---@param path string|string[]: Either a `.` separated string of table keys, or a list.
M.tbl_ensure = function(t, path)
    local keys = type(path) == "table" and path or vim.split(path, ".", {plain = true})

    if not M.tbl_access(t, keys) then
        M.tbl_set(t, keys, {})
    end
end

---Turn a *vector* into a new *table*
---@generic T
---@param v Vector<T>
---@return table<T, boolean>
M.vec2tbl = function(v)
    local ret = {}
    for _, val in ipairs(v) do
        ret[val] = true
    end

    return ret
end

---Return a `vector` with duplicates filtered out
---@generic T
---@param vec T[]
---@return T[]
M.vec_filter_dupes = function(vec)
    local seen = {}
    local ret = {}

    for _, v in ipairs(vec) do
        if not seen[v] then
            ret[#ret + 1] = v
            seen[v] = true
        end
    end
    return ret
end

---Shift a `vector` `n` elements in-place
---@param tbl table Table to shift
---@param n number number of elements to shift
M.vec_shift = function(tbl, n)
    for _ = 1, n do
        table.insert(tbl, 1, table.remove(tbl, #tbl))
    end
end

---Create a shallow copy of a portion of a vector.
---@generic T
---@param t T[]
---@param first? integer First index, inclusive
---@param last? integer Last index, inclusive
---@return T[] sliced vector
M.vec_slice = function(t, first, last)
    local slice = {}
    for i = first or 1, last or #t do
        table.insert(slice, t[i])
    end

    return slice
end

---Join multiple vectors into one.
---@generic T
---@vararg T[]
---@return T[]
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

---Get the result of the union of the given vectors.
---@generic T
---@vararg T[]
---@return T[]
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
---@generic T
---@vararg T[]
---@return T[]
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
---@generic T
---@vararg T[]
---@return T[]
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

---Find an item in a vector
---@generic T
---@param haystack T[]
---@param matcher fun(v: T): boolean
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
---@generic T
---@param tbl T[]: Vector to search
---@param val T Item to find
---@return boolean
M.vec_contains = function(tbl, val)
    -- return vim.tbl_contains(t, value)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end

    return false
end

---Return first index a given object can be found in a vector,
---or -1 if it's not present.
---@generic T
---@param tbl T[]: Vector to search
---@param val T Item to find
---@return integer
M.vec_indexof = function(tbl, val)
    for i, vt in ipairs(tbl) do
        if vt == val then
            return i
        end
    end
    return -1
end

---Append any number of objects to the end of a vector.
---@generic T
---@param t T[] Vector to push to
---@return T[] vec #Vector with the pushed value
M.vec_push = function(t, ...)
    for _, v in ipairs({...}) do
        t[#t + 1] = v
    end
    return t
end

---Execute a function across a table, keeping an accumulation of results
---@generic T: table
---@param tbl T[]
---@param func fun(T, T, key: string|number): T
---@param acc T
---@return T
M.fold = function(tbl, func, acc)
    acc = acc or {}
    for k, v in pairs(tbl) do
        acc = func(acc, v, k)
        assert(acc ~= nil, "Accumulator must be returned on each iteration")
    end
    return acc
end

---Apply a function to each value in a `vector`. Return the `vector`
---@generic T: table
---@param tbl T[]
---@param func fun(T, key: string|number): T
---@return T[]
M.map = function(tbl, func)
    -- return vim.tbl_map(func, tbl)

    return M.fold(
        tbl,
        function(acc, v, k)
            table.insert(acc, func(v, k, acc))
            return acc
        end,
        {}
    )
end

---Apply function to each element of `vector`
---@generic T
---@param tbl T[] A list of elements
---@param func fun(v: T) Function to be applied
M.for_each = function(tbl, func)
    for _, item in ipairs(tbl) do
        func(item)
    end
end

---Filter table based on function
---@generic T
---@param tbl T[] Table to be filtered
---@param func fun(v: T) Function to apply filter
---@return T[]
M.filter = function(tbl, func)
    return vim.tbl_filter(func, tbl)
end

---Apply a function to each element of a vector
---Returning true if *any* element matches `func`
---@generic T
---@param tbl T[] A list of elements
---@param func fun(v: T) Function to be applied
---@return boolean
M.any = function(tbl, func)
    for _, v in pairs(tbl) do
        if func(v) then
            return true
        end
    end

    return false
end

---Apply a function to each element of a vector
---Returning true if *all* elements match `func`
---@generic T
---@param tbl T[] A list of elements
---@param func fun(v: T) Function to be applied
---@return boolean
M.all = function(tbl, func)
    for _, v in pairs(tbl) do
        if not func(v) then
            return false
        end
    end

    return true
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
        bufnr = {
            bufnr,
            function(b)
                return (type(b) == "number" and b >= 1) or type(b) == "nil"
            end,
            "number >= 1 or nil"
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

---@class ListBufsSpec
---@field loaded boolean Filter out buffers that aren't loaded
---@field valid boolean Filter out buffers that aren't valid
---@field listed boolean Filter out buffers that aren't listed
---@field modified boolean Filter out buffers that aren't modified
---@field empty boolean Filter out buffers that are empty
---@field no_hidden boolean Filter out buffers that are hidden
---@field tabpage number Filter out buffers that are not displayed in a given tabpage.
---@field bufname string Filter out buffers whose name doesn't match a given Lua pattern
---@field bufpath string Filter out buffers whose *full-path* doesn't match a given Lua pattern
---@field options { [string]: any } Filter out buffers that don't match a given map of options
---@field vars { [string]: any } Filter out buffers that don't match a given map of variables

---List buffers matching options
---@param opts? ListBufsSpec
---@return number[]
M.list_bufs = function(opts)
    vim.validate {
        loaded = {opts.loaded, {"b"}, true},
        valid = {opts.valid, {"b"}, true},
        listed = {opts.listed, {"b"}, true},
        modified = {opts.modified, {"b"}, true},
        empty = {opts.empty, {"b"}, true},
        no_hidden = {opts.no_hidden, {"b"}, true},
        tabpage = {opts.tabpage, {"n"}, true},
        bufname = {opts.bufname, {"s"}, true},
        bufpath = {opts.bufpath, {"s"}, true},
        options = {opts.options, {"t"}, true},
        vars = {opts.vars, {"t"}, true}
    }

    opts = opts or {}
    ---@type number[]
    local bufs

    if opts.no_hidden or opts.tabpage then
        local wins = opts.tabpage and api.nvim_tabpage_list_wins(opts.tabpage) or api.nvim_list_wins()
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
        function(bufnr)
            if opts.loaded and not api.nvim_buf_is_loaded(bufnr) then
                return false
            end

            if opts.valid and not M.buf_is_valid(bufnr) then
                return false
            end

            if opts.listed and not vim.bo[bufnr].buflisted then
                return false
            end

            if opts.modified and not M.buf_is_modified(bufnr) then
                return false
            end

            if opts.empty and M.buf_is_empty(bufnr) then
                return false
            end

            if opts.bufname and not fn.bufname(bufnr):match(opts.bufname) then
                return false
            end

            if opts.bufpath and not api.nvim_buf_get_name(bufnr):match(opts.bufpath) then
                return false
            end

            if opts.options then
                for option, value in pairs(opts.options) do
                    -- if vim.bo[bufnr][option] ~= value then
                    --     return false
                    -- end

                    local ok, v = pcall(api.nvim_buf_get_option, bufnr, option)
                    if not ok or v ~= value then
                        return false
                    end
                end
            end

            if opts.vars then
                for var, value in pairs(opts.vars) do
                    -- if vim.b[bufnr][var] ~= value then
                    --     return false
                    -- end

                    local ok, v = pcall(api.nvim_buf_get_var, bufnr, var)
                    if not ok or v ~= value then
                        return false
                    end
                end
            end
            return true
        end
    )
end

---Get buffer info of buffers that match given options
---@param opts ListBufsSpec
---@return number[]
M.buf_info = function(opts)
    return M.map(
        M.list_bufs(opts),
        function(bufnr)
            return fn.getbufinfo(bufnr)
        end
    )
end

---Return the buffer lines, proper line endings for 'dos' format
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

---Call the function `f`, ignoring most window/buffer autocmds
---@param f function
---@return boolean, any
M.no_win_event_call = function(f)
    local last = vim.o.eventignore
    ---@diagnostic disable-next-line: undefined-field
    vim.opt.eventignore:prepend(
        M.list {
            "WinEnter",
            "WinLeave",
            "WinNew",
            "WinClosed",
            "BufWinEnter",
            "BufWinLeave",
            "BufEnter",
            "BufLeave"
        }
    )
    local ok, err = pcall(f)
    vim.opt.eventignore = last

    return ok, err
end

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
    return fn.win_gettype() == "popup" or api.nvim_win_get_config(winid).relative ~= ""
    --
    -- These two commands here are not equivalent as the docs might suggest
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
    if M.is_floating_window(winid) then
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
---@return number[]?
M.get_wins_of_type = function(wintype)
    return M.filter(
        api.nvim_list_wins(),
        function(winid)
            return fn.win_gettype(winid) == wintype
        end
    )
end

---Return a table of window ID's for quickfix windows
---@return number?
M.get_qfwin = function()
    return M.get_wins_of_type("quickfix")[1]
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Reload                          │
-- ╰──────────────────────────────────────────────────────────╯
---Reload all lua modules
M.reload_config = function()
    -- Handle impatient.nvim automatically.
    ---@diagnostic disable-next-line:undefined-field
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
---@param path string module to invalidate
---@param recursive boolean? should the module be invalidated recursively?
---@param req boolean? should a require be returned? If used with recursive, top module is returned
---@return module?
M.reload_module = function(path, recursive, req)
    path = vim.trim(path)

    if recursive then
        local to_return
        for key, value in pairs(package.loaded) do
            if key ~= "_G" and value and fn.match(key, path) ~= -1 then
                package.loaded[key] = nil
                if req then
                    local r = require(key)
                    if key:sub(1, #path) == path then
                        to_return = r
                    end
                end
            end
        end
        if req then
            return to_return
        end
    else
        package.loaded[path] = nil
        if req then
            return require(path)
        end
    end
end

---Note: this function returns the currently loaded state
---Given certain assumptions i.e. it will only be true if the plugin has been
---loaded e.g. lazy loading will return false
---@param plugin_name string
---@return boolean?
M.plugin_loaded = function(plugin_name)
    local plugins = packer_plugins or {}
    return plugins[plugin_name] and plugins[plugin_name].loaded
end

local installed
---Check if a plugin is on installed. Doesn't have to be loaded
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

-- defer_plugin: defer loading plugin until timeout passes
---@param plugin string
---@param timeout number
M.defer_plugin = function(plugin, timeout)
    vim.defer_fn(
        function()
            require("plugins").loader(plugin)
        end,
        timeout or 0
    )
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
---@return string|table
M.list = function(value, str, sep)
    sep = sep or ","
    str = str or ""
    value = F.tern(type(value) == "table", table.concat(value, sep), value)
    return F.tern(str ~= "", table.concat({value, str}, sep), value)
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                          Async                           │
-- ╰──────────────────────────────────────────────────────────╯
---Set a timeout
---@param callback function
---@param ms number
---@return userdata
M.setTimeout = function(callback, ms)
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

---@param ms number
---@return Promise
M.wait = function(ms)
    return require("promise")(
        function(resolve)
            local timer = uv.new_timer()
            timer:start(
                ms,
                0,
                function()
                    timer:close()
                    resolve()
                end
            )
        end
    )
end

-- ╭──────────────────────────────────────────────────────────╮
-- │                       Switch-case                        │
-- ╰──────────────────────────────────────────────────────────╯

---Switch/case statement. Allows return statement
---
---Usage:
---```lua
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
---```
---@param c table
---@return table
M.switch = function(c)
    local swtbl = {
        casevar = c,
        caseof = function(self, code)
            local f
            if self.casevar then
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

-- Examples:  https://github.com/luvit/luv/tree/master/examples

return M
