---@module 'dev'
---@description Lowest level utility functions that will also be used in `common.utils`
---@class DevL
local M = {}

local log = require("common.log")

local F = vim.F

--  ╭──────╮
--  │ Wrap │
--  ╰──────╯

---Ternary helper for when `is_if` might be a falsy value, and you can't
---compose the expression as `cond and is_if or is_else`.
---
---The outcomes may be given as lists where the first index is a callable object,
---and the subsequent elements are args to be passed to the callable if the outcome
---is to be evaluated.
---
---```c
--- // c
--- cond ? "yes" : "no"
--- cond ? foo(1, 2) : bar(3)
---```
---
---```lua
--- -- lua
--- ternary(cond, "yes", "no")
--- ternary(cond, { foo, 1, 2 }, { bar, 3 })
---```
---@generic T, V
---@param cond? boolean|fun():boolean Statement to be tested
---@param is_if T Return if cond is truthy
---@param is_else V Return if cond is not truthy
---@param simple? boolean Never treat `is_if` and `is_else` as arg lists
---@return unknown
F.tern = function(cond, is_if, is_else, simple)
    -- TODO: Would like to be able to pass boolean and treat as cond == true
    if cond then
        if not simple and type(is_if) == "table" and vim.is_callable(is_if[1]) then
            return is_if[1](M.vec_select(is_if, 2))
        end
        return is_if
    else
        if not simple and type(is_else) == "table" and vim.is_callable(is_else[1]) then
            return is_else[1](M.vec_select(is_else, 2))
        end
        return is_else
    end
end

---Return a value based on two values
---@generic T, V
---@param cond boolean|nil Statement to be tested
---@param is_if T Return if condition is truthy
---@param is_else V Return if condition is not truthy
---@return T | V
F.if_expr = function(cond, is_if, is_else)
    return F.tern(cond, is_if, is_else, true)
end

---## if else nil
---Similar to `vim.F.nil` except that:
---   - a default value can be given
---   - `if cond == nil then want else default`
---@generic T, V
---@param cond any Value to check if `nil`
---@param is_nil T Value to return if `cond` is `nil`
---@param is_not_nil V Value to return if `cond` is not `nil`
---@return T | V
F.ife_nil = function(cond, is_nil, is_not_nil)
    return F.if_expr(cond == nil, is_nil, is_not_nil)
end

---## if else not nil
---Similar to `vim.F.nil` except that:
---   - a default value can be given
---   - value is checked to be not nil
---   - `if cond ~= nil then want else default`
---@generic T, V
---@param cond any Value to check if `not nil`
---@param is_not_nil T Value to return if `cond` is `not nil`
---@param is_not_not_nil V Value to return if `cond` is not `not nil`
---@return T | V
F.ife_nnil = function(cond, is_not_nil, is_not_not_nil)
    return F.if_expr(cond ~= nil, is_not_nil, is_not_not_nil)
end

---## if else true
---Similar to `vim.F.nil` except that:
---   - a default value can be given
---   - value is checked to be true
---   - `if cond == true then want else default`
---@generic T, V
---@param cond any Value to check if `true`
---@param is_true T Value to return if `cond` is `true`
---@param is_not_true V Value to return if `cond` is not `true`
---@return T | V
F.ife_true = function(cond, is_true, is_not_true)
    return F.if_expr(cond == true, is_true, is_not_true)
end

---## if else false
---Similar to `vim.F.nil` except that:
---   - a default value can be given
---   - value is checked to be false
---   - `if cond == false then want else default`
---@generic T, V
---@param cond any Value to check if `false`
---@param is_false T Value to return if `cond` is `false`
---@param is_not_false V Value to return if `cond` is not `false`
---@return T | V
F.ife_false = function(cond, is_false, is_not_false)
    return F.if_expr(cond == false, is_false, is_not_false)
end

---## if then
---Return a default value if `val` is truthy
---   - `if val then want else val`
---@generic T, V
---@param val T value to check
---@param thenv V default value to return if `val` is truthy
---@return T|V
F.if_then = function(val, thenv)
    return F.if_expr(val, thenv, val)
end

---## if nil then
---Return a default value if `val` is nil
---   - `if val == nil then default else val`
---   - `ifn_then`
---@generic T, V
---@param val T value to check if `nil`
---@param default V default value to return if `val` is `nil`
---@return T | V
F.unwrap_or = function(val, default)
    if type(val) ~= "table" then
        return F.ife_nil(val, default, val)
    end
    val = vim.deepcopy(val or {})
    for k, v in pairs(default) do
        if val[k] == nil then
            val[k] = v
        end
    end
    return val
end

---## if not nil then
---Return a default value if `val` is `not nil`
---   - `if val ~= nil then want else val`
---   - `ifnn_then`
---@generic T, V
---@param val T value to check if not `nil`
---@param is_nnil V default value to return if `val` is `not nil`
---@return T | V
F.nnil_or = function(val, is_nnil)
    return F.ife_nnil(val, is_nnil, val)
end

---## if true then
---Return a default value if `val` is `true`
---   - `if val == true then want else val`
---   - `ift_then`
---@generic T, V
---@param val T value to check if `true`
---@param is_true V default value to return if `val` is `true`
---@return T | V
F.true_or = function(val, is_true)
    return F.ife_true(val, is_true, val)
end

---## if false then
---Return a default value if `val` is `false`
---   - `if val == false then want else val`
---   - `iff_then`
---@generic T, V
---@param val T value to check if `false`
---@param is_false V default value to return if `val` is `false`
---@return T | V
F.false_or = function(val, is_false)
    return F.ife_false(val, is_false, val)
end

---@generic T any
---@param eq any
---@return fun(...: T[]): T?
local function if_fn(eq)
    return function(...)
        local nargs = select("#", ...)
        for i = 1, nargs do
            local v = select(i, ...)
            if v == eq then
                return v
            end
        end
        return nil
    end
end

---Returns the first argument which is true.
---If no arguments are true, nil is returned.
F.if_true = if_fn(true)

---Returns the first argument which is false.
---If no arguments are false, nil is returned.
F.if_false = if_fn(false)

---Use in combination with pcall
---@generic T
---@param status boolean
---@param ... `T`
---@return T?
M.ok_or_nil = function(status, ...)
    if not status then
        local args = _t({...})
        local msg = args:concat("\n"):split("\n")
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
---@param func T<fun(v: V): `R`?>
---@param ... V
---@return R?
M.npcall = function(func, ...)
    return M.ok_or_nil(pcall(func, ...))
end

---Wrap a function to return `nil` if it fails, otherwise the value
---## Example:
---```lua
---require('dev').nil_wrap(require)('ufo')
---```
---@generic T: fun()
---@param func `T`
---@return T<fun(v: any): any?>
M.nil_wrap = function(func)
    return function(...)
        return M.npcall(func, ...)
    end
end

-- ---@overload fun(func: fun(...<T:unknown>):<R:any>, ...<T:unknown>): boolean, <R:any>

---Call the given function and use `vim.notify` to notify of any errors
---this function is a wrapper around `xpcall` which allows having a single
---error handler for all errors
---@generic T: ..., R: any
---@param msg string
---@param func fun(...: T): R Function to be called
---@param ... T Arguments that are passed to `func`
---@return boolean, R
---@overload fun(func: fun(...: T): R, ...: T): boolean, R
function M.xpcall(msg, func, ...)
    local args = {...}
    if type(msg) == "function" then
        func, args, msg = msg, {func, unpack(args)}, nil --[[@as nil]]
    end

    local f = __FILE__()
    local tb = __TRACEBACK__()

    return xpcall(
        func,
        function(err)
            local errsp = err:split("\n")
            local title = F.unwrap_or(msg, errsp[1])
            local body = F.if_expr(msg == nil, _t(errsp):slice(2), _t(errsp))
            M.vec_insert(body, "", ("File     : %s"):format(f), ("Traceback: %s"):format(tb), "")

            vim.schedule(
                function()
                    log.err(body, {title = title, once = true})
                end
            )
        end,
        unpack(args)
    )
end

-- ---@generic T: ..., R
-- ---@generic M: ...
-- ---@param fn fun(...: T, ...: M): R Function to be called
-- ---@param ... `T` Arguments that are passed to `fn`
-- ---@return fun(...: M): R fn Function that will accept more arguments

-- ---@generic T, R
-- ---@generic A: any?, B: any?, C: any?, D: any?
-- ---@param fn fun(...: T, a1: A, a2: B, a3: C, a4: D): R Function to be called
-- ---@param ... T Arguments that are passed to `fn`
-- ---@return fun(a1: A, a2: B, a3: C, a4: D): R fn Function that will accept more arguments

---Bind a function to some arguments and return a new function that can be called later
---Useful for setting up callbacks without anonymous functions
---@generic A1, T: ...
---@generic R
---@generic F: fun(a1: A1, ...: T):R
---@param func F Function to be called
---@param ... T Arguments that are passed to `fn`
---@return F:fun(...:T):R fn Function that will accept more arguments
M.thunk = function(func, ...)
    local bound = {...}
    return function(...)
        return func(unpack(vim.list_extend(vim.list_extend({}, bound), {...})))
    end
end

-- M.bind = M.thunk
-- M.ibind = M.ithunk
-- M.pibind = M.pithunk

---Like `thunk()`, but arguments passed to the thunk are ignored
---@generic T: ..., R
---@param func fun(...: T): R Function to be called
---@param ... T Arguments that are passed to `fn`
---@return fun(): R fn Function that will not accept more arguments
M.ithunk = function(func, ...)
    local bound = {...}
    return function()
        return func(unpack(bound))
    end
end

---Same as `ithunk()`, except prefixed with a `pcall`
---@generic T: ..., R
---@param func fun(...: T): R Function to be called
---@param ... T Arguments that are passed to `fn`
---@return fun(): R fn Function that will not accept more arguments
M.pithunk = function(func, ...)
    return M.ithunk(pcall, func, ...)
end

---Call a function one time
---@generic T: ..., R
---@param func fun(a: T): R
---@return fun(a: T): R
M.once = function(func)
    local called = false
    return function(...)
        if not called then
            called = true
            return func(...)
        end
    end
end

---Return cached function value for next call
---@generic T: ..., R
---@param func fun(a: T): R function that will take at least one arg
---@return fun(a: T): R function with at least one arg, used as the key
M.memoize = function(func)
    local cache = {}
    return function(...)
        local res = cache[...]
        if res == nil then
            res = func(...)
            cache[...] = res
        end
        return res
    end
end

--  ══════════════════════════════════════════════════════════════════════

---@param value number
---@return number
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

---Determine whether two tables/vectors are equivalent
---@param t1 table<any, any>|Vector<any>
---@param t2 table<any, any>|Vector<any>
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
---@param tbl table
M.tbl_clear = function(tbl)
    for k, _ in pairs(tbl) do
        tbl[k] = nil
    end
    -- return M.fold(
    --     t,
    --     function(acc, _, k)
    --         acc[k] = nil
    --         return acc
    --     end,
    --     t
    -- )
end

---Clone a table
---@generic K, V
---@param tbl table<K, V>: Table to clone
---@return table<K, V>?
M.tbl_clone = function(tbl)
    if not tbl then
        return
    end
    local clone = {}

    for k, v in pairs(tbl) do
        clone[k] = v
    end

    return clone
end

---Deep extend a table, while performing a union on all the sub-tables.
---@generic K, V: any
---@param tbl table<K, V>
---@param ... any
---@return table<K, V>
M.tbl_union_extend = function(tbl, ...)
    local res = M.tbl_clone(tbl)

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

---Try property access into a table
---@generic T : table
---@param tbl T Table to index into
---@param path string|string[] Either a `.` separated string of table keys, or a list.
---@return T?
M.tbl_access = function(tbl, path)
    -- vim.defaulttable(func)
    -- vim.tbl_get()
    local keys = type(path) == "table"
        and path
        or vim.split(path, ".", {plain = true})

    local cur = tbl

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
---@param tbl table Table to index into
---@param path string|string[]: Either a `.` separated string of table keys, or a list.
---@param value any
M.tbl_set = function(tbl, path, value)
    local keys = type(path) == "table"
        and path
        or vim.split(path, ".", {plain = true})

    local cur = tbl

    for i = 1, #keys - 1 do
        local k = keys[i]

        if not cur[k] then
            cur[k] = {}
        end

        cur = cur[k]
    end

    cur[keys[#keys]] = value
end

---Ensure that the table path is a valid in `tbl`
---@param tbl table
---@param path string|string[] Either a `.` separated string of table keys, or a list.
M.tbl_ensure = function(tbl, path)
    local keys = type(path) == "table"
        and path
        or vim.split(path, ".", {plain = true})

    if not M.tbl_access(tbl, keys) then
        M.tbl_set(tbl, keys, {})
    end
end

---Perform a `map` and `filter` out index values that would become or are `nil`
---@generic K, V
---@param tbl table<K, V>
---@param func fun(v: V): any?
---@return table<K, V>
M.tbl_fmap = function(tbl, func)
    return M.fold(
        tbl,
        function(acc, v, k)
            local ret = func(v)
            if ret ~= nil then
                if type(k) == "number" then
                    table.insert(acc, ret)
                else
                    acc[k] = ret
                end
            end
            return acc
        end,
        {}
    )
end

---Convert a table into a key, value table of tables
---@generic K, V
---@param tbl table<K, V>
---@return table<K, V>[]
M.kv_pairs = function(tbl)
    return M.fold(
        tbl,
        function(acc, v, k)
            table.insert(acc, {k, v})
            return acc
        end,
        {}
    )
end

---Create table whose keys are now the values, and the values are now the keys
---Similar to `vim.tbl_add_reverse_lookup`
---
---Assumes that the values in tbl are unique and hashable (no `nil`)
---@generic K, V
---@param tbl table<K, V>
---@return table<V, K>
M.kv_reverse = function(tbl)
    return M.fold(
        tbl,
        function(acc, v, k)
            acc[v] = k
            return acc
        end,
        {}
    )
end

---Apply a function to key-value table pairs
---@generic T, K: string|number, V: any
---@param tbl T<table<K, V>|Vector<V>>
---@param func fun(val: V, key?: K, acc?: T): `T`
---@return table<K, V>[]
M.kv_map = function(tbl, func)
    return M.map(M.kv_pairs(tbl), func)
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

--  ╭──────────────────────────────────────────────────────────╮
--  │                          Vector                          │
--  ╰──────────────────────────────────────────────────────────╯

---Turn a `vector` into a `table`
---@generic T
---@param vec Vector<T>
---@return table<T, boolean>
M.vec2tbl = function(vec)
    local ret = {}
    for _, val in ipairs(vec) do
        ret[val] = true
    end

    return ret
end

---Find an item in a vector or table's values
---@generic T
---@param haystack Vector<T>|table<any, T>
---@param matcher fun(v: T): boolean
---@return T
M.vec_find = function(haystack, matcher)
    local found
    for _, needle in ipairs(haystack) do
        if matcher(needle) then
            found = needle
            break
        end
    end
    return found
end

---Return a vector with duplicates filtered out
---@generic T
---@param vec Vector<T>
---@return Vector<T>
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

---Shift a vector `n` elements in-place
---@param vec Vector<any> Vector to shift
---@param n number Number of elements to shift
M.vec_shift = function(vec, n)
    for _ = 1, n do
        table.insert(vec, 1, table.remove(vec, #vec))
    end
end

---Join multiple vectors into one
---@generic T
---@param ... Vector<T>
---@return Vector<T>
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

---Join a vector into a string
---@param vec Vector<any> Vector to join
---@param sep string Separator to join the the vector
---@return string
M.vec_joins = function(vec, sep)
    return table.concat(vim.tbl_map(tostring, vec), sep)
end

---Get the result of the union of the given vectors
---@generic T
---@param ... Vector<T>
---@return Vector<T>
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
---@param ... Vector<T>
---@return Vector<T>
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
---@param ... Vector<T>
---@return Vector<T>
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
---@return Vector<T> #sliced vector
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
---@return T ...
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
---@param ... Vector<T>
---@return Vector<T> vec #Vector with the pushed value
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
---@return Vector<T> vec #Vector with the pushed value
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

---Filter vector based on function
---@generic T
---@param vec Vector<T> Vector to be filtered
---@param func fun(v: T): boolean Function to apply filter
---@return Vector<T>?
M.filter = function(vec, func)
    return vim.tbl_filter(func, vec)
end

--  ╭──────────────────────────────────────────────────────────╮
--  │                     Vector and Table                     │
--  ╰──────────────────────────────────────────────────────────╯

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
---@param func fun(acc: T, val: V, key?: K): `T`
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
---@generic T, K: string|number, V: any
---@param tbl T<table<K, V>|Vector<V>>
---@param func fun(val: V, key?: K, acc?: T): `T`
---@return T
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

---Apply function to each element of vector as argument
---@generic T, K: string|number, V: any
---@param tbl T<table<K, V>|Vector<V>> Table to be filtered
---@param func fun(val: V, key?: K) Function to each element
M.foreach = function(tbl, func)
    M.fold(tbl, function(acc, v, k)
        func(v, k)
        return acc
    end, {})
end

---Flatten a table
---@generic T, K: string|number, V: any
---@param tbl T<table<K, V>|Vector<V>> table to be flattened
---@param shallow? boolean shallow flatten
---@param ret? T table return
---@return Vector<V>
M.flatten = function(tbl, shallow, ret)
    ret = ret or {}
    M.foreach(tbl, function(val, _key)
        if type(val) == "table" then
            if shallow then
                M.foreach(val, function(v, _k)
                    table.insert(ret, v)
                end)
            else
                M.flatten(val, false, ret)
            end
        else
            table.insert(ret, val)
        end
    end)
    return ret
end

M.tbl = {
    equivalent = M.tbl_equivalent,
    clear = M.tbl_clear,
    clone = M.tbl_clone,
    union_extend = M.tbl_union_extend,
    access = M.access,
    set = M.set,
    ensure = M.ensure,
    fmap = M.tbl_fmap,
    map = M.map,
    fold = M.fold,
    kv_pairs = M.kv_pairs,
    kv_reverse = M.kv_reverse,
    kv_map = M.kv_map,
    any = M.any,
    all = M.all,
}

M.vec = {
    find = M.vec_find,
    totbl = M.vec2tbl,
    shift = M.vec_shift,
    join = M.vec_join,
    union = M.vec_union,
    diff = M.vec_diff,
    symdiff = M.vec_symdiff,
    slice = M.vec_slice,
    select = M.vec_select,
    contains = M.vec_contains,
    indexof = M.vec_indexof,
    push = M.vec_push,
    insert = M.vec_insert,
    remove = M.vec_remove,
    fmap = M.tbl_fmap,
    filter = M.filter,
    foreach = M.foreach,
    any = M.any,
    all = M.all,
    map = M.map,
    fold = M.fold,
}

vim.F = F

return M
