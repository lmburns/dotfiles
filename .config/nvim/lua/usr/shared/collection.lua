---@module 'usr.shared.collection'
---@class Usr.Collection
local M = {}

---@class PackedTable<K, V> : {n: integer, [K]: V}, {n: integer, [integer]: K}

---Like {...} except preserve table length explicitly
---@generic K, V
---@param ... table<K, V>|V
---@return PackedTable<K, V>|PackedTable<integer, V>
function M.pack(...)
    return {n = select("#", ...), ...}
end

---Similar to `unpack()`, but use length set by C.pack if present
---@generic K, V, T
---@param t PackedTable<K, V>|PackedTable<integer, V>
---@param i? integer
---@param j? integer
---@return ... V
function M.unpack(t, i, j)
    return unpack(t, i or 1, j or t.n or #t)
end

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
---@param ... any
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
---```lua
---  local v = {1, 2, 3}
---  M.vec_insert(v, 4, 5, {6, 7}) == {4, 5, {6, 7}, 1, 2, 3}
---```
---@generic T
---@param vec Vector<T> Vector to push to
---@param ... any
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
    M.fold(
        tbl,
        function(acc, v, k)
            func(v, k)
            return acc
        end,
        {}
    )
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

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---@class Usr.Collection.Tbl
M.tbl = {
    pack = M.pack,
    unpack = M.unpack,
    equivalent = M.tbl_equivalent,
    clear = M.tbl_clear,
    clone = M.tbl_clone,
    union_extend = M.tbl_union_extend,
    access = M.tbl_access,
    set = M.tbl_set,
    ensure = M.tbl_ensure,
    fmap = M.tbl_fmap,
    map = M.map,
    fold = M.fold,
    filter = M.filter,
    foreach = M.foreach,
    kv_pairs = M.kv_pairs,
    kv_reverse = M.kv_reverse,
    kv_map = M.kv_map,
    any = M.any,
    all = M.all,
}

---@class Usr.Collection.Vec
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

return M
