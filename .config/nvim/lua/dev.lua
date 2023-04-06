--@module common.utils
---@description: Lowest level utility functions that will also be used in `common.utils`

local M = {}

local log = require("common.log")

local fn = vim.fn
local api = vim.api
local uv = vim.loop
local env = vim.env
local F = vim.F

---@class Array<T>: { [integer]: T }
---@class Vector<T>: { [integer]: T }
---@class Dict<T>: { [string]: T }
---@class Hash<T>: { [string]: T }

---@diagnostic disable-next-line:duplicate-doc-alias
---@alias module table

-- ╒══════════════════════════════════════════════════════════╕
--                            Global
-- ╘══════════════════════════════════════════════════════════╛

---Print text nicely, joined with newlines
---@param ... any
_G.pln = function(...)
    local argc = select("#", ...)
    local msg_tbl = _t({})
    for i = 1, argc do
        local arg = select(i, ...)
        msg_tbl:insert(M.inspect(arg))
    end

    print(table.concat(msg_tbl, "\n\n"))
end

---Print text nicely, joined with spaces
---@param ... any
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

---Format a string
---See: https://fmt.dev/latest/syntax.html
---See: https://github.com/starwing/lua-fmt
---format_spec ::=  [[fill]align][sign]["#"]["0"][width][grouping]["." precision][type]
---fill        ::=  <a character other than '{' or '}'>
---align       ::=  "<" | ">" | "^"
---sign        ::=  "+" | "-" | " "
---width       ::=  integer | "{" [arg_id] "}"
---grouping    ::=  "_" | ","
---precision   ::=  integer | "{" [arg_id] "}"
---type        ::=  int_type | flt_type | str_type
---int_type    ::=  "b" | "B" | "d" | "o" | "x" | "X" | "c"
---flt_type    ::=  "e" | "E" | "f" | "F" | "g" | "G" | "%"
---str_type    ::=  "p" | "s"
---@param ... any
_G.printf = function(...)
    p(require("fmt")(...))
end

--  ╭────────╮
--  │ String │
--  ╰────────╯

---Escape a string correctly
---@param self string
---@return string
string.escape = function(self)
    return vim.pesc(self)
end

---Trims whitespace on left and right side by default.
---Can trim characters from both sides as well.
---@param self string
---@param chars? string
---@return string
string.trim = function(self, chars)
    if not chars then
        return self:match("^[%s]*(.-)[%s]*$")
    end
    chars = chars:escape()
    return self:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end

---Trims whitespace on right side by default.
---Can trim characters from right as well.
---@param self string
---@param chars? string
---@return string
string.rtrim = function(self, chars)
    if not chars then
        return self:match("^(.-)[%s]*$")
    end
    chars = chars:escape()
    return self:match("^(.-)[" .. chars .. "]*$")
end

---Trims whitespace on left side by default.
---Can trim characters from left as well.
---@param self string
---@param chars? string
---@return string
string.ltrim = function(self, chars)
    if not chars then
        return self:match("^[%s]*(.-)$")
    end
    chars = chars:escape()
    return self:match("^[" .. chars .. "]*(.-)$")
end

---Replace multiple spaces with a single space
---@param self string
---@return string, integer
string.compact = function(self)
    return self:gsub("%s+", " ")
end

---Capitalizes the first letter of a string
---@param self string
---@return string
string.capitalize = function(self)
    local ret = self:sub(1, 1):upper() .. self:sub(2):lower()
    return ret
end

---Split a string on ` ` by default. Optional delimiter.
---@param self string
---@param delim? string
---@return string[]
string.split = function(self, delim)
    return vim.split(self, delim or " ")
end

---Use PCRE regular expressions in Lua. Does the same as `string.gmatch`
---@param self string
---@param pattern string
---@return fun(): string[]
string.rxmatch = function(self, pattern)
    return require("rex_pcre2").gmatch(self, pattern)
end

---Use PCRE regular expressions in Lua. Does the same as `string.gsub`
---## Example
---```lua
---print(('what up'):rxsub('(\\w+)', '%1 %1'))      -- => what what up up
---print(('what  up dude'):rxsub('\\s{2,}', 'XX'))  -- => whatXXup dude
---```
---@param self string
---@param pattern string
---@param repl string|string[]|function(s: string)
---@param n? number Maximum number of matches to  search for
---@return string, number
string.rxsub = function(self, pattern, repl, n)
    return require("rex_pcre2").gsub(self, pattern, repl, n)
end

---Use PCRE regular expressions in Lua. Does the same as `string.find`
---@param self string
---@param pattern string
---@param init? number Start offset in the subject (can be negative)
---@return number start
---@return number end
---@return any ... captured
string.rxfind = function(self, pattern, init)
    return require("rex_pcre2").find(self, pattern, init)
end

---Use PCRE regular expressions to split a string
---@param self string
---@param sep string
---@return fun(): string[]
string.rxsplit = function(self, sep)
    return require("rex_pcre2").split(self, sep)
end

---Use PCRE regular expressions to count number of matches in string
---@param self string
---@param pattern string
---@return number
string.rxcount = function(self, pattern)
    return require("rex_pcre2").count(self, pattern)
end

---Use `vim.regex` to match a string
---@param self string
---@param pattern string
---@return number?
---@return number?
string.vmatch = function(self, pattern)
    return vim.regex(pattern):match_str(self)
end

---Load or `loadstring`
---@param str string
---@return fun(s: string): any
M.dostring = function(str)
    return assert((loadstring or load)(str))()
end

--  ╭───────╮
--  │ Other │
--  ╰───────╯

---Cache the output of lambda expressions
local lambda_cache = {}

---Execute a lambda expression
---## Example
---```lua
---print(D.lambda("x -> x + 2")(2)) -- prints: 4
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

local ripairs_iter = function(t, i)
    i = i - 1
    local v = t[i]
    if v ~= nil then
        return i, v
    end
end

---Reverse `ipairs`
---@generic T: table, V
---@param t T
---@return fun(table: V[], i?: number): number, V
---@return T
---@return number i
_G.ripairs = function(t)
    return ripairs_iter, t, (#t + 1)
end

-- ╒══════════════════════════════════════════════════════════╕
--                      Development tools
-- ╘══════════════════════════════════════════════════════════╛

---Use in combination with pcall
---@generic T
---@param status boolean
---@param ... `T`
---@return `T`?
M.ok_or_nil = function(status, ...)
    if not status then
        local args = {...}
        local msg = vim.split(table.concat(args, "\n"), "\n")
        local mod = msg[1]:match("module '(%w.*)'")
        M.vec_insert(
            msg,
            ("File     : %s"):format(__FILE__()),
            ("Traceback: %s"):format(__TRACEBACK__()),
            ""
        )
        vim.schedule(
            function()
                log.err(msg, {
                    title = ('Failed to require("%s")'):format(mod),
                    once = true,
                })
            end
        )
        return
    end
    return ...
end

---Nil `pcall`.
---If `pcall` succeeds, return result of `fn`, else `nil`
---## Example:
---```lua
---require('dev').npcall(require, 'ufo')
---```
---@generic V, R
---@generic T: fun()
---@param fn T<fun(v: V): R?>
---@param ... V
---@return R?
M.npcall = function(fn, ...)
    return M.ok_or_nil(pcall(fn, ...))
end

---Wrap a function to return `nil` if it fails, otherwise the value
---## Example:
---```lua
---require('dev').nil_wrap(require)('ufo')
---```
---@generic T: fun()
---@param fn `T`
---@return `T`<fun(v: any): any?>
M.nil_wrap = function(fn)
    return function(...)
        return M.npcall(fn, ...)
    end
end

---Call the given function and use `vim.notify` to notify of any errors
---this function is a wrapper around `xpcall` which allows having a single
---error handler for all errors
---@param msg string|fun()|nil
---@param func function
---@vararg any
---@return boolean, any
---@overload fun(fn: function, ...): boolean, any
M.wrap_err = function(msg, func, ...)
    local args = {...}
    if type(msg) == "function" then
        args, func, msg = {func, unpack(args)}, msg, nil
    end

    local f = __FILE__()
    local tb = __TRACEBACK__()

    return xpcall(
        func,
        function(err)
            local errsp = err:split("\n")
            local title = utils.get_default(msg, errsp[1])
            local body = F.tern(msg == nil, _t(errsp):slice(2), _t(errsp))
            M.vec_insert(
                body,
                "",
                ("File     : %s"):format(f),
                ("Traceback: %s"):format(tb),
                ""
            )

            vim.schedule(
                function()
                    log.err(body, {title = title, once = true})
                end
            )
        end,
        unpack(args)
    )
end

--@generic T, V: ...
--@param fn fun(v1: T, v2?: V)
--@param ... T
--@return fun(v2: V)

---Bind a function to some arguments and return a new function (the thunk) that can be called later
---Useful for setting up callbacks without anonymous functions
---@generic T: ..., V: ..., R
---@param fn fun(v1: T): R Function to be called
---@param ... T Arguments that are passed to `fn`
---@return fun(v2: V): R fn Function that will accept more arguments
M.thunk = function(fn, ...)
    local bound = {...}
    return function(...)
        return fn(unpack(vim.list_extend(vim.list_extend({}, bound), {...})))
    end
end

---Like `thunk()`, but arguments passed to the thunk are ignored
--- ### Example
---```lua
---  map("n", "yd", dev.ithunk(require("common.yank").yank_reg, vim.v.register, fn.expand("%:p:h")))
---```
---@generic T: ..., R
---@param fn fun(v1: T): R Function to be called
---@param ... T Arguments that are passed to `fn`
---@return fun(none: nil): R fn Function that will not accept more arguments
M.ithunk = function(fn, ...)
    local bound = {...}
    return function()
        return fn(unpack(bound))
    end
end

---Same as `ithunk()`, except prefixed with a `pcall`
---@generic T: ..., R
---@param fn fun(v1: T): R Function to be called
---@param ... T Arguments that are passed to `fn`
---@return fun(none: nil): R fn Function that will not accept more arguments
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
---@param cmd string
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

-- vim.spairs => Enumerate a table sorted by its keys
-- vim.defaulttable => Table members created when accessed (defaultdict)

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
---@param ignore_mt? boolean Ignore metatable
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

---Deep extend a table, while performing a union on all the sub-tables.
---@generic K, V: any
---@param t table<K, V>
---@param ... any
---@return table<K, V>
M.tbl_union_extend = function(t, ...)
    local res = M.tbl_clone(t)

    ---@generic K, V
    ---@param ours table<K, V>
    ---@param theirs table<K, V>
    ---@return table<K, V>
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

---Try property access into a table.
---@generic T : table
---@param t T Table to index into
---@param path string|string[]: Either a `.` separated string of table keys, or a list.
---@return T?
M.tbl_access = function(t, path)
    local keys = type(path) == "table" and path or
        vim.split(path, ".", {plain = true})

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
    local keys = type(path) == "table" and path or
        vim.split(path, ".", {plain = true})

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
    local keys = type(path) == "table" and path or
        vim.split(path, ".", {plain = true})

    if not M.tbl_access(t, keys) then
        M.tbl_set(t, keys, {})
    end
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Vector                          │
--  ╰──────────────────────────────────────────────────────────╯

---Find an item in a vector or table's values
---@generic T
---@param haystack T[]|table<any, T>
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

---Turn a `vector` into a new `table`
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
            ret[#ret+1] = v
            seen[v] = true
        end
    end
    return ret
end

---Shift a `vector` `n` elements in-place
---@param vec Vector<any> Vector to shift
---@param n number number of elements to shift
M.vec_shift = function(vec, n)
    for _ = 1, n do
        table.insert(vec, 1, table.remove(vec, #vec))
    end
end

---Join multiple vectors into one
---@generic T
---@param ... T[]
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
---@param ... T[]
---@return T[]
M.vec_union = function(...)
    local result = {}
    local args = {...}
    local seen = {}

    for i = 1, select("#", ...) do
        if type(args[i]) ~= "nil" then
            if type(args[i]) ~= "table" and not seen[args[i]] then
                seen[args[i]] = true
                result[#result+1] = args[i]
            else
                for _, v in ipairs(args[i]) do
                    if not seen[v] then
                        seen[v] = true
                        result[#result+1] = v
                    end
                end
            end
        end
    end

    return result
end

---Get the result of the difference of the given vectors.
---@generic T
---@param ... T[]
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
---@param ... T[]
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
            result[#result+1] = v
        end
    end

    return result
end

---Create a shallow copy of a portion of a vector.
---Can index with negative numbers.
---@generic T
---@param vec Vector<T> Vector to select from
---@param first? integer First index, inclusive
---@param last? integer Last index, inclusive
---@return T[] #sliced vector
M.vec_slice = function(vec, first, last)
    -- return vim.list_slice(vec, first, last)
    local slice = {}

    if first and first < 0 then
        first = #vec + first + 1
    end

    if last and last < 0 then
        last = #vec + last + 1
    end

    for i = first or 1, last or #vec do
        table.insert(slice, vec[i])
    end

    return slice
end

---Return all elements in `t` between `first` and `last` index.
---Can index with negative numbers.
---@generic T
---@param vec Vector<T> Vector to select from
---@param first? number First index, inclusive
---@param last? number Last index, inclusive
---@return any ...
M.vec_select = function(vec, first, last)
    return unpack(M.vec_slice(vec, first, last))
end

---Search for a value in a vector
---@generic T
---@param vec Vector<T>: Vector to search
---@param val T Item to find
---@return boolean
M.vec_contains = function(vec, val)
    return vim.tbl_contains(vec, val)
end

---Return first index a given object can be found in a vector,
---or -1 if it's not present.
---@generic T
---@param vec Vector<T>: Vector to search
---@param val T Item to find
---@return number
M.vec_indexof = function(vec, val)
    for i, vt in ipairs(vec) do
        if vt == val then
            return i
        end
    end
    return -1
end

---Append any number of objects to the end of a vector.
---@generic T
---@param vec Vector<T> Vector to push to
---@return T[] vec #Vector with the pushed value
M.vec_push = function(vec, ...)
    for _, v in ipairs({...}) do
        vec[#vec+1] = v
    end
    return vec
end

---Insert any number of objects to the beginning of a vector.
---The items passed will be inserted in the same sequence.
---```
---local v = {1, 2, 3}
---M.vec_insert(v, 4, 5, {6, 7}) == {4, 5, {6, 7}, 1, 2, 3}
---```
---@generic T
---@param vec Vector<T> Vector to push to
---@return T[] vec #Vector with the pushed value
M.vec_insert = function(vec, ...)
    for _, v in ripairs({...}) do
        table.insert(vec, 1, v)
    end
    return vec
end

---Remove an object from a vector
---@generic T
---@param t Vector<T>
---@param v T
---@return boolean success True if the object was removed
M.vec_remove = function(t, v)
    local idx = M.vec_indexof(t, v)
    if idx > -1 then
        table.remove(t, idx)

        return true
    end
    return false
end

--@generic T: table|any[], K: string|number, V: any
--@param tbl `T`
--@param func fun(acc: T<K, V>, val: V, key?: K): T<K, V>
--@param acc T<K, V>
--@return T<K, V>

--@generic K: string|number, V: any
--@param tbl table<K, V>|Vector<V>
--@param func fun(acc: table<`K`, `V`>|Vector<`V`>, val: `V`, key?: `K`): table<`K`, `V`>|Vector<`V`>
--@param acc table<K, V>|Vector<V>
--@return table<K, V>|Vector<V>

---Execute a function across a table, keeping an accumulation of results
---@generic T, K: string|number, V: any
---@param tbl T<table<K, V>|Vector<V>>
---@param func fun(acc: `T`, val: `V`, key?: `K`): `T`
---@param acc `T`
---@return `T`
M.fold = function(tbl, func, acc)
    acc = acc or {}
    for k, v in pairs(tbl) do
        acc = func(acc, v, k)
        assert(acc ~= nil, "Accumulator must be returned on each iteration")
    end
    return acc
end

---Apply a function to each value in a `vector`. Return the `vector`
---@generic T, K: string|number, V: any
---@param tbl T<table<K, V>|Vector<V>>
---@param func fun(val: `V`, key?: `K`, acc?: `T`): `T`
---@return `T`
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

---Perform a `map` and `filter` out index values that would become `nil`.
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

---Filter table based on function
---@generic T
---@param tbl T[] Table to be filtered
---@param func fun(v: T): boolean Function to apply filter
---@return T[]?
M.filter = function(tbl, func)
    return vim.tbl_filter(func, tbl)
end

---Apply function to with each element of `vector` as argument
---@generic T
---@param tbl T[] A list of elements
---@param func fun(v: T) Function to be applied
M.for_each = function(tbl, func)
    for _, item in ipairs(tbl) do
        func(item)
    end
end

---Apply a function to each element of a vector
---Returning true if *any* element matches `func`
---@generic T
---@param tbl T[] A list of elements
---@param func fun(v: T): boolean Function to be applied
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
---@param func fun(v: T): boolean Function to be applied
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

---`vim.api.nvim_buf_is_loaded` filters out all hidden buffers
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
    vim.validate{
        bufnr = {
            bufnr,
            function(b)
                return (type(b) == "number" and b >= 1) or type(b) == "nil"
            end,
            "number >= 1 or nil"
        },
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
---@field buftype string|string[] Filter out buffers that are not of a certain type
---@field bufname string Filter out buffers whose name doesn't match a given Lua pattern
---@field bufpath string Filter out buffers whose *full-path* doesn't match a given Lua pattern
---@field options { [string]: any } Filter out buffers that don't match a given map of options
---@field vars { [string]: any } Filter out buffers that don't match a given map of variables

---List buffers matching options
---@param opts? ListBufsSpec
---@return number[]
M.list_bufs = function(opts)
    opts = opts or {}

    vim.validate{
        loaded = {opts.loaded, {"b"}, true},
        valid = {opts.valid, {"b"}, true},
        listed = {opts.listed, {"b"}, true},
        modified = {opts.modified, {"b"}, true},
        empty = {opts.empty, {"b"}, true},
        no_hidden = {opts.no_hidden, {"b"}, true},
        tabpage = {opts.tabpage, {"n"}, true},
        buftype = {opts.buftype, {"s", "t"}, true},
        bufname = {opts.bufname, {"s"}, true},
        bufpath = {opts.bufpath, {"s"}, true},
        options = {opts.options, {"t"}, true},
        vars = {opts.vars, {"t"}, true},
    }

    ---@type number[]
    local bufs

    if opts.no_hidden or opts.tabpage then
        local wins =
            opts.tabpage and api.nvim_tabpage_list_wins(opts.tabpage) or
            api.nvim_list_wins()
        local bufnr
        ---@type { [number]: boolean }
        local seen = {}
        ---@type number[]
        bufs = {}
        for _, winid in ipairs(wins) do
            bufnr = api.nvim_win_get_buf(winid)
            if not seen[bufnr] then
                table.insert(bufs, bufnr)
            end
            seen[bufnr] = true
        end
    else
        ---@type number[]
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

            -- Have to check for "" buftype
            if type(opts.buftype) == "string" and not vim.bo[bufnr].buftype == opts.buftype then
                return false
            end

            if type(opts.buftype) == "table" then
                for _, bt in ipairs(opts.buftype) do
                    if type(bt) == "string" and not vim.bo[bufnr].buftype == bt then
                        return false
                    end
                end
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
            return fn.getbufinfo(bufnr) --[==[@as Array<Dict<any>>]==]
        end
    )
end

---Return the buffer lines, proper line endings for 'dos' format
---@param bufnr? number
---@return string[]
M.buf_lines = function(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf() --[==[@as number]==]
    local buftext = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    if vim.bo[bufnr].ff == "dos" then
        for i = 1, #buftext do
            buftext[i] = buftext[i] .. "\r"
        end
    end
    return buftext
end

---Check if the buffer name matches a terminal buffer name
---@param bufname? string
---@return boolean
M.is_term_bufname = function(bufname)
    bufname = utils.get_default(bufname, fn.bufname())
    if bufname:match("term://") then
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

---Sets the current buffer in a window, without side effects
---@param win number
---@param buf number
M.win_set_buf_noautocmd = function(win, buf)
    local ei = vim.o.eventignore
    vim.o.eventignore = "all"
    api.nvim_win_set_buf(win, buf)
    vim.o.eventignore = ei
end

---Determine if the window is the only one open
---@param win_id? number
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
---@param winid? number
---@return boolean
M.is_floating_window = function(winid)
    return fn.win_gettype() == "popup" or
        api.nvim_win_get_config(winid or 0).relative ~= ""
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

--  ╭──────────────────────────────────────────────────────────╮
--  │                    Modules / Plugins                     │
--  ╰──────────────────────────────────────────────────────────╯

---Reload all lua modules
M.reload_config = function()
    -- Handle impatient.nvim automatically.
    ---@diagnostic disable-next-line:undefined-field
    local luacache = (_G.__luacache or {}).modpaths.cache

    -- local lua_dirs = fn.glob(("%s/lua/*"):format(dirs.config), 0, 1)
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
        local dirs = fn.expand(fn.stdpath("data") .. "/site/pack/packer/start/*",
                               true, true)
        local opt = fn.expand(fn.stdpath("data") .. "/site/pack/packer/opt/*",
                              true, true)
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

---defer_plugin: defer loading plugin until timeout passes
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
---@param sep? string: Separator to concatenate the table
---@param str? string: String to concatenate to the table
---@return string
M.list = function(value, sep, str)
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
---@return uv_timer_t?
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
        end,
    }
    return swtbl
end

-- Examples:  https://github.com/luvit/luv/tree/master/examples

return M
