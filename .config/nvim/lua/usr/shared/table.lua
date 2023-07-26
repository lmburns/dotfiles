---@module 'usr.shared.table'
---@description Object-oriented table class
---@class Usr.Shared.Table
local M = {}

-- local carray = require("carray")
-- local oop = lazy.require("usr.lib.oop") ---@module 'usr.lib.oop'
local lazy = require("usr.lazy")
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'
local F = lazy.require("usr.shared.F") ---@module 'usr.shared.F'
local table_id = {"table_t"}

---Inherits from all parents
---@param cls Table_t
---@param parents any[]
local function inherit(cls, parents)
    cls.__index = cls
    cls.__super = parents
    local cls_parents = {
        __index = function(_, key)
            for i = 1, #parents do
                local found = parents[i][key]
                if found then
                    return found
                end
            end
        end,
    }
    setmetatable(cls, cls_parents)
    setmetatable(parents, cls_parents)
end

---@param o any
---@param expected_t string
---@return any
local function assert_t(o, expected_t)
    local actual_t = type(o)
    local deb2 = debug.getinfo(2, "n")
    -- local deb3 = debug.getinfo(3)

    local step = 1
    local curr = debug.getinfo(1)
    local info = debug.getinfo(step)
    while info and info.source == curr.source do
        step = step + 1
        info = debug.getinfo(step)
    end
    info = info or curr

    local fmt = "[%s] [Table:%s]: %s expected, got %s"
    local mod = log.module_fmt(info.source)
    return assert(
        actual_t == expected_t,
        fmt:format(
            ("%s.%s:%d"):format(mod, info.name, info.currentline),
            deb2.name or "",
            expected_t,
            actual_t
        )
    )
end

-- M.groupby()
-- M.countby()
-- M.binsearch()

---@class Table_t: table,tablelib
---@field __super? tablelib
---@operator call:Table_t
---@operator concat:string
local Table = {__id = table_id}
inherit(Table, {table})

---Creates a new `Table` from the given table.
---@generic K, V
---@param t? table<K, V>
---@param clone? boolean
---@return Table_t
function Table.new(t, clone)
    if t then
        assert_t(t, "table")
        if clone then
            t = vim.deepcopy(t)
        end
    end
    t = t or {}
    local o = Table.is_instance(t) and t or setmetatable(t, Table)
    return o
end

---Creates a new `Table` filled with a value.
---@generic K, V
---@param t table<K, V>
---@param value any
---@param start? integer
---@param fin? integer
---@return Table_t
function Table.fill(t, value, start, fin)
    local o = Table.new(t)
    for i = start or 1, fin or 10 do
        o[i] = value
    end
    return o
end

---Creates a new `Table` of zeros.
---@param count integer
---@return Table_t
function Table.zeros(count)
    assert_t(count, "number")
    return Table.fill({}, 0, 1, count)
end

---Creates a new `Table` of ones.
---@param count integer
---@return Table_t
function Table.ones(count)
    assert_t(count, "number")
    return Table.fill({}, 0, 1, count)
end

---Creates a new `Table` filled with incrementing values.
---@generic K, V
---@param t table<K, V>
---@param start integer
---@param fin integer
---@return Table_t
function Table.range(t, start, fin)
    assert_t(start, "number")
    assert_t(fin, "number")
    local o = Table.new(t)
    for i = start, fin do
        o[i] = i
    end
    return o
end

-- ---@class Table_t.Packed<K, V>: Table_t<K, V>, PackedTable<K, V>
-- ---@class Table_t.Packed: Table_t, {n: integer}
---@class Table_t.Packed<K, V>: Table_t<K, V>|{n: integer}

---Similar to `unpack()`, but use length set by C.pack if present
---@generic K, V
---@param i? integer
---@param j? integer
---@return ... V
function Table:unpack(i, j)
    ---@cast self Table_t.Packed
    return unpack(self, i or 1, j or self.n or self:size())
end

-- ---@return Table_t.Packed<K, V>|Table_t.Packed<integer, V>

---Like `{...}` except preserve table length explicitly
---@generic K, V, T
---@param ... table<K, V>|V
---@return Table_t
function Table.pack(...)
    return Table.new({n = select("#", ...), ...})
end

---Remove the metatable
---@return self
function Table:clean()
    setmetatable(self, nil)
    return self
end

---Perl style autovivification table
---@param func? fun(key: any): any function called to create a missing value
---@return Table_t
function Table.autoviv(func)
    func = func or function(_)
        return Table.autoviv()
    end
    return Table.new(
        setmetatable({}, {
            __index = function(tbl, key)
                rawset(tbl, key, func(key))
                return rawget(tbl, key)
            end,
        })
    )
end

---
---@return string
function Table:__tostring()
    local cloned = self:deep_copy()
    setmetatable(cloned, nil)
    return vim.inspect(cloned)
end

-- function Table:__concat()
-- end

---Allows calling `#tbl` to return the actual size of the table
---@return integer
function Table:__len()
    return self:size()
end

---Compares two tables for equality. It does not care about the named orders,
-- however it greatly cares about the order of the index keys.
---@param other Table_t
---@return boolean
function Table:__eq(other)
    local other_t = type(other)

    if other_t ~= "table" then
        return false
    end
    if not Table.is_instance(other) then
        other = Table.new(other)
    end
    if self:deep_size() ~= other:deep_size() then
        return false
    end

    for k, _ in pairs(self) do
        if self[k] ~= other[k] then
            return false
        end
    end
    for k, _ in pairs(other) do
        if self[k] == nil then
            return false
        end
    end
    return true
    -- return vim.deep_equal(self, other)
end

---@param o any
---@return boolean
function Table.is_instance(o)
    return type(o) == "table" and o.__id == table_id
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Return true of the table contains the key
---@see Table_t.contains    # checks for key with table equalities
---@see Table_t.contains_fn # checks for key with a function
---@see Table_t.indexof     # returns index of item or 0
---@param key string|integer
---@return boolean
function Table:has(key)
    return self[key] ~= nil
end

---Returns the item from the table
---@see Table_t.find    # returns item; checks with function
---@see Table_t.indexof # returns index of item or 0
---@param key integer|string
---@return any
---@nodiscard
function Table:get(key)
    if type(key) == "number" then
        if key < 0 then
            key = self:size() + key + 1
        end
    end
    return self[key]
end

---Returns the number of elements in the table. This function is equivalent to `#list`.
---```lua
---  _j({a = true, 2, {3, 4}}):getn() == 2
---  _j({a = true, 2, {3, 4}}):size() == 3
---  _j({a = true, 2, {3, 4}}):deep_size() == 4
---```
---@see Table_t.size      # return number of elements in table (key-value or just value)
---@see Table_t.deep_size # return number of elements in table + sub-tables
---@return integer
---@nodiscard
function Table:getn()
    return #self
end

---Returns the length of the table.
---```lua
---  _j({a = true, 2, {3, 4}}):getn() == 2
---  _j({a = true, 2, {3, 4}}):size() == 3
---  _j({a = true, 2, {3, 4}}):deep_size() == 4
---```
---@see Table_t.getn      # return number of elements in table
---@see Table_t.deep_size # return number of elements in table + sub-tables
---@return number
function Table:size()
    local count = 0
    self:each(function(_)
        count = count + 1
    end)
    return count
end

---Returns the length of the table including the map items.
---```lua
---  _j({a = true, 2, {3, 4}}):getn() == 2
---  _j({a = true, 2, {3, 4}}):size() == 3
---  _j({a = true, 2, {3, 4}}):deep_size() == 4
---```
---@see Table_t.size      # return number of elements in table (key-value or just value)
---@see Table_t.getn      # return number of elements in table
---@return number
function Table:deep_size()
    local count = 0
    for _, v in pairs(self) do
        count = type(v) == "table" and count + Table.deep_size(v) or count + 1
    end
    return count
end

---Inserts element `value` at position `pos` in `list`
---@param position integer|any
---@param value any
---@return self
---@overload fun(value: any)
function Table:insert(position, value)
    if value == nil then
        self.__super.insert(self, position)
    else
        self.__super.insert(self, position, value)
    end
    return self
end

-- ---Return Table_t after inserting
-- ---@param ... any either a value to insert, or a position and value
-- ---@return self
-- function Table:insert_and_then(...)
--     self:insert(...)
--     return self
-- end

---Removes from `list` the element at position `pos`, returning the value of the removed element.
---@param pos? integer
---@return any
function Table:remove(pos)
    pos = math.min(pos or 1, self:size())
    return self.__super.remove(self, pos)
end

---Return Table_t after removing instead of the value removed
---@param pos? integer
---@return self
function Table:remove_and_then(pos)
    self:remove(pos)
    return self
end

---Remove and return the last element from the table
---@return any
function Table:pop()
    return self:remove(self:size())
end

---Remove and return the first element from the table
---@return any
function Table:shift()
    return self:remove(1)
end

---Moves elements from table `a1` to table `a2`.
---```lua
---  -- old syntax
---  local vals = {1,45,2,9,3,101,401,28,43}
---  local ss = {}
---  for i = 2, 5 do
---    table.insert(ss, vals[i])
---  end
---  -- new
---  local subset = table.move(values, 2, 5, 1, {})
---  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
---  local t1 = Table.new({1,2,3,4,5,6,7,8,9})
---  local t2 = t1:move({1,3,1})
---  p(t2)   --> {1, 2, 3}
---  p(t1)   --> {1, 2, 3, 4, 5, 6, 7, 8, 9}
---  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
---  -- Can remove elements line:
---  local t1 = {1, 2, 3, 4, 5, 6, 7, 8, 9}
---  local t2 = Table.new({}):move(1, 3, #t1-3, t1)  --> {1, 2, 3, 4, 5, [9] = 9}
---```
---@generic T
---@param ifrom  integer
---@param iend   integer
---@param inc    integer
---@param tbl2? Table_t<T>
---@return Table_t<T>|table
function Table:move(ifrom, iend, inc, tbl2)
    local new = type(tbl2) ~= "table" and Table.new({}) or tbl2
    self.__super.move(self, ifrom, iend, inc, new)
    return new
end

---Given a list where all elements are strings or numbers, returns the string
---`list[i]..sep..list[i+1] ··· sep..list[j]`.
---@param separator? string
---@param index?     integer
---@param eindex?    integer
---@return string
---@nodiscard
function Table:concat(separator, index, eindex)
    return self.__super.concat(self, separator, index, eindex)
end

---Return the largest number in the table of numbers
---Return the longest string in a table of strings
---Does not work on key-value tables
---@return integer|string
---@nodiscard
function Table:maxn()
    local typ = type(self:get(1))
    local max = -math.huge
    local item = ""
    if typ == "string" then
        self:each(function(val)
            if type(val) == typ and #val > max then
                item = val
                max = #val
            end
        end)
    else
        self:each(function(val)
            if type(val) == typ and val > max then
                max = val
            end
        end)
    end
    return typ == "string" and item or max
end

---Return the smallest number in the table of numbers
---Return the shortest string in a table of strings
---Does not work on key-value tables
---@return integer|string
---@nodiscard
function Table:minn()
    local typ = type(self:get(1))
    local min = math.huge
    local item = ""
    if typ == "string" then
        self:each(function(val)
            if type(val) == typ and #val < min then
                item = val
                min = #val
            end
        end)
    else
        self:each(function(val)
            if type(val) == typ and val < min then
                min = val
            end
        end)
    end
    return typ == "string" and item or min
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Returns a new `Table` that contains only the values of the table
---@return self
function Table:values()
    return self:fold(function(acc, v, _k)
        acc:insert(v)
        return acc
    end, Table.new({}))
end

---Returns a new `Table` that contains only the keys of the table
---@return self
function Table:keys()
    return self:fold(function(acc, _v, k)
        acc:insert(k)
        return acc
    end, Table.new({}))
end

---Turn a vector into a table
---@return Table_t
function Table:vec2tbl()
    return self:map(function(v, _k, acc)
        acc[v] = true
    end)
end

---Invert a table's keys and values
---@return Table_t
function Table:invert()
    return self:folds(function(acc, v, k)
        acc[v] = k
        acc[k] = nil;
        return acc
    end)
end

---Turn a vector into a table by adding it's index as a key
---@return Table_t
function Table:add_reverse_lookup()
    return self:folds(function(acc, v, k)
        acc[v] = k
        return acc
    end)
end

---Enumerate a table
---Turns a key-value table into a vector
---Opposite of Table:vec2tbl()
---@param on_keys? boolean use keys instead of values
---@return Table_t
function Table:enumerate(on_keys)
    local i = 1
    return self:map(function(v, k, acc)
        if on_keys then
            acc[i] = k
        else
            acc[i] = v
        end
        acc[k] = nil
        i = i + 1
    end)
end

---Checks if a table is empty
---@return boolean
function Table:isempty()
    return next(self) == nil
end

---Check if table can be treated as an array (table indexed by integers).
---Empty table is considered an array
---@return boolean
function Table:isarray()
    for k, _ in pairs(self) do
        if not (type(k) == "number" and k == math.floor(k)) then
            return false
        end
    end
    return true
end

---Check if table can be treated as a list (table indexed by consecutive integers starting from 1).
---Empty table is considered a list
---@return boolean
function Table:islist()
    for i = 1, self:size() do
        if self[i] == nil then
            return false
        end
    end
    return true
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Execute a function across a table, keeping an accumulation of results
---@generic A, K: string|number, V: any
---@param func fun(acc: A, val: V, key?: K): `A`
---@param acc A accumulator
---@return A
function Table:fold(func, acc)
    assert_t(func, "function")
    acc = F.unwrap_or(acc, Table.new({}))
    for k, v in pairs(self) do
        acc = func(acc, v, k)
        assert(acc ~= nil, "[Table:fold]: accumulator must be returned each iteration")
    end
    return acc
end

---Execute a function across a table starting at the end, keeping an accumulation of results
---@generic A, K: string|number, V: any
---@param func fun(acc: A, val: V, key?: K): `A`
---@param acc A accumulator
---@return A
function Table:foldr(func, acc)
    assert_t(func, "function")
    acc = F.unwrap_or(acc, Table.new({}))
    for k, v in pairs(self:reverse()) do
        acc = func(acc, v, k)
        assert(acc ~= nil, "[Table:foldr]: accumulator must be returned each iteration")
    end
    return acc
end

---Equivalent to `Table:fold()`, but fold on **c**lone
---@generic A, K: string|number, V: any
---@param func fun(acc: A, val: V, key?: K): `A`
---@return A
function Table:foldc(func)
    return self:fold(func, Table.new({}))
end

---Equivalent to `Table:fold()`, but fold on **s**elf
---@generic A, K: string|number, V: any
---@param func fun(acc: A, val: V, key?: K): `A`
---@return A
function Table:folds(func)
    return self:fold(func, self)
end

---Runs the function for each item in the table, transforming it in the process.
---@generic T, K: string|number, V: any
---@param func fun(val: V, key?: K, acc?: T): T?
---@param clone? boolean should a new table be used
---@return self
function Table:map(func, clone)
    assert_t(func, "function")
    return self:fold(function(acc, v, k)
        acc[k] = func(v, k, acc)
        return acc
    end, F.tern(clone, Table.new({}), self))
end

---Apply function to each element of vector as argument
---@generic T, K: string|number, V: any
---@param func fun(val: V, key?: K, acc?: T) function ran on each element
function Table:each(func)
    self:fold(function(acc, v, k)
        func(v, k, acc)
        return acc
    end, {})
end

---Perform a `map` and `filter` out index values that would become or are `nil`
---@generic T, K: string|number, V: any
---@param func fun(val: V, key?: K, acc?: T): T?
---@return self
function Table:fmap(func)
    assert_t(func, "function")
    return self:fold(function(acc, v, k)
        local ret = func(v, k, acc)
        if ret ~= nil then
            if type(k) == "number" then
                acc:insert(ret)
            else
                acc[k] = ret
            end
        end
        return acc
    end, Table.new({}))
end

---Apply a function to key-value table pairs
---@generic T, K: string|number, V: any
---@param func fun(val: V, key?: K, acc?: T): `T`
---@return Table_t
function Table:kv_map(func)
    return self:kv_pairs():map(func)
end

---Flatten a table
---```lua
---  Table.new({1, 2, 3, {1, 2, 3}}):flatten() --> {1, 2, 3, 1, 2, 3}
---```
---@param shallow? boolean
---@return self
function Table:flatten(shallow)
    local new = Table.new()
    local function flatten(tbl, shal)
        local len = #tbl
        for i = 1, len do
            local val = tbl[i]
            if type(val) == "table" then
                if shal then
                    for _, v in ipairs(val) do
                        new:insert(v)
                    end
                else
                    flatten(val, false)
                end
            elseif val then
                new:insert(val)
            end
        end
    end
    flatten(self, shallow)
    return new
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---## in-place
---Shift a **list-like** table `n` elements
---@param n number Number of elements to shift
---@return self
function Table:rotate(n)
    for _ = 1, n do
        self:insert(1, self:remove(#self))
    end
    return self
end

---Append any number of objects to the end of a table
---@param ... any
---@return Table_t
function Table:push(...)
    local values = Table.new({...})
    values:each(function(v)
        self[self:size()+1] = v
    end)
    return self
end

---Insert items at beginning of list in reverse order
---@param ... any
---@return Table_t
function Table:unshift(...)
    local values = Table.new({...})
    values:reverse():each(function(v)
        self:insert(1, v)
    end)
    return self
end

---Swap two regions in array
---```lua
---  Table.new({{1, 2, 3}, {4, 5}}):block_swap(1, 2, 1) --> {{4, 5}, {1, 2, 3}}
---  Table.new({1, 2, 3, 4, 5, 6}):block_swap(2, 3, 1)  --> {1, 3, 2, 4, 5, 6}
---  Table.new({1, 2, 3, 4, 5, 6}):block_swap(2, 3, 2)  --> {1, 3, 2, 3, 5, 6}
---  Table.new({1, 2, 3, 4, 5, 6}):block_swap(2, 4, 1)  --> {1, 4, 3, 2, 5, 6}
---```
---@param idx1 integer index of first block/position
---@param idx2 integer index of second block/position
---@param count integer positions to shift
---@return self
function Table:block_swap(idx1, idx2, count)
    local block = Table.new({})
    local n = 0
    local t = self
    for i = idx1, (idx1 + count - 1) do
        block:insert(t[i])
        t[i] = t[idx2 + n]
        n = n + 1
    end

    n = 1
    for i = idx2, (idx2 + count - 1) do
        t[i] = block[n]
        n = n + 1
    end

    return t
end

---Executes the fn function on the whole table and returns a new `Table`.
---@param func fun(v: Table_t): table will pass the `Table` to the function
---@return self
function Table:exec(func)
    assert_t(func, "function")
    return Table.new(func(self))
end

---Returns the max element (or element-based computation)
---@generic T, K: string|number, V: any
---@param func? fun(val: V, key?: K, acc?: T): integer
---@return integer
function Table:max(func)
    if self:isempty() then
        return -math.huge
    elseif type(func) == "function" then
        local max = {computed = -math.huge}
        self:each(function(v, k, acc)
            local comp = func(v, k, acc)
            if comp >= max.computed then
                max = {computed = comp, value = v}
            end
        end)
        return max.value
    else
        return math.max(unpack(self) --[[@as integer]])
    end
end

---Returns the min element (or element-based computation)
---@generic T, K: string|number, V: any
---@param func? fun(val: V, key?: K, acc?: T): integer
---@return integer
function Table:min(func)
    if self:isempty() then
        return math.huge
    elseif type(func) == "function" then
        local min = {computed = math.huge}
        self:each(function(v, k, acc)
            local comp = func(v, k, acc)
            if comp < min.computed then
                min = {computed = comp, value = v}
            end
        end)
        return min.value
    else
        return math.min(unpack(self) --[[@as integer]])
    end
end

---Merge two tables.
---Note that the new indices of the second table will be adjusted to the first table.
---@param dup? boolean|table|Table_t if true it will duplicate indexed values
---@param ... table tables to merge
---@return Table_t
---@overload fun(...: table|Table_t)
function Table:merge(dup, ...)
    local args = {...}
    if type(dup) == "table" then
        args = {dup, ...}
        dup = nil
    end
    local cloned = self:deep_copy()
    local seen = Table.new({})
    self:each(function(v, k)
        if type(k) == "number" then
            seen[v] = true
        end
    end)
    Table.new(args):flatten(true):each(function(v, k)
        if type(k) == "string" then
            cloned[k] = v
        else
            if dup or not seen[v] then
                cloned:insert(v)
            end
        end
    end)
    return cloned
end

-- TODO: which to use?

---
---@param ... table tables to merge
---@return Table_t
function Table:extend(...)
    local args = Table.new({...})
    args:each(function(other)
        if not Table.is_instance(other) then
            other = Table.new(other)
        end
        other:each(function(_v, k)
            if type(k) == "number" then
                self:insert(other[k])
            else
                self[k] = other[k]
            end
        end)
    end)
    return self
end

---Prefer values from the tables that are not passed
---@param ... table
---@return Table_t
function Table:deep_merge(...)
    return Table.new(vim.tbl_deep_extend("keep", self, ...))
end

---Prefer values from the tables that are passed
---@param ... table
---@return Table_t
function Table:deep_mergef(...)
    return Table.new(vim.tbl_deep_extend("force", self, ...))
end

---Trim all falsy values from the table
---@return self
function Table:compact()
    return self:filter(function(v)
        return not (not v)
    end)
end

---Check if the fn returns true for at least one entry of the table.
---@see Table_t.has         # simple check for key validity
---@see Table_t.contains    # checks for key with table equalities
---@param func fun(v: any): boolean calls on each entry of t
---@return boolean
function Table:contains_fn(func)
    assert_t(func, "function")
    local item, ok = self:find(func)
    return ok and item ~= nil
end

---Return true of the table contains the value.
---@see Table_t.has         # simple check for key validity
---@see Table_t.contains_fn # checks for key with a function
---@param val any
---@return boolean
function Table:contains(val)
    if type(val) == "table" then
        val = Table.new(val)
    end
    -- return self:contains_fn(function(v)
    --     if type(v) == "table" then
    --         return Table.new(v) == val
    --     end
    --     return v == val
    -- end)
    return self:any(function(v)
        if type(v) == "table" then
            return Table.new(v) == val
        end
        return v == val
    end)
end

---Return first index if found in a table, or 0 if it's not present.
---@see Table_t.get        # returns item regardless
---@see Table_t.find       # returns item; checks with function
---@see Table_t.find_index # returns index of item or 0 (with function)
---@param val any
---@param start? integer
---@return integer
function Table:indexof(val, start)
    start = start or 1
    for i = start, self:size() do
        if val == self[i] then
            return i
        end
    end
    return 0
end

---Return first index is found in a table starting from the end, or 0 if it's not present
---@param val any
---@param start? integer
---@return integer
function Table:rindexof(val, start)
    start = start or self:size()
    for i = start, 1, -1 do
        if val == self[i] then
            return i
        end
    end
    return 0
end

---Returns the first entry for which the fn functions returns true. If the
---returned value is nil, you should check the boolean value of the returned to
---determine if the value was found or not.
---@see Table_t.get     # returns item regardless
---@see Table_t.indexof # returns index of item or 0
---@param func fun(v: any): boolean
---@return any
---@return boolean
function Table:find(func)
    assert_t(func, "function")
    for _, item in pairs(self) do
        if func(item) then
            return item, true
        end
    end
    return nil, false
end

---Similar to `Table:indexof()` except a function is used
---@generic T
---@param func fun(idx: integer, value: any, args: T): boolean
---@param ... T
---@return integer
function Table:find_index(func, ...)
    assert_t(func, "function")
    for i = 1, self:size() do
        if func(i, self[i], ...) then
            return i
        end
    end
    return 0
end

---Counts occurrences of a given value in a table.
---For the total number of items in the table, see `Table:size()`.
---@param value? any item to be found in the table
---@return integer number occurrences of the given value
function Table:count(value)
    if not value then
        return self:size()
    end
    local count = 0
    self:each(function(v)
        if v == value then
            count = count + 1
        end
    end)
    return count
end

---Return true if all values in a table matche predicate
---@generic T, K: string|number, V: any
---@param func fun(val: V, key: K, acc: T): boolean
---@return boolean
function Table:all(func)
    assert_t(func, "function")
    local found = true
    self:each(function(v, k, acc)
        if found and not func(v, k, acc) then
            found = false
        end
    end)

    return found
end

---Return true if any value in a table matches predicate
---@generic T, K: string|number, V: any
---@param func fun(val: V, key: K, acc: T): boolean
---@return boolean
function Table:any(func)
    local found = false
    self:each(function(v, k, acc)
        if not found and func(v, k, acc) then
            found = true
        end
    end)

    return found
end

---Filters the table if the function returns true.
---@generic T, K: string|number, V: any
---@param func fun(val: V, key: K, acc: T): boolean?
---@return Table_t
function Table:filter(func)
    assert_t(func, "function")
    local found = Table.new({})
    self:each(function(v, k, acc)
        if func(v, k, acc) then
            if type(k) == "number" then
                found:insert(v)
            else
                found[k] = v
            end
        end
    end)

    return found
end

---Convenient `filter` to select only items with specific `key:value` pairs
---The `Table_t` should be a table of tables
---```lua
---  Table.new({{a = 3, d = 6}, b = 4, {c = 5}}):where({a = 3}) --> {{a = 3, d = 6}}
---```
---@see Table_t.pluck  # return value of key in a table of tables
---@see Table_t.pick   # return table with allow properties
---@param prop table
---@return self
function Table:where(prop)
    if not Table.is_instance(prop) then
        prop = Table.new(prop)
    end
    return self:filter(function(val)
        if type(val) == "table" then
            return prop:all(function(v, k)
                return val[k] == v
            end)
        end
    end)
end

---Return a copy of the table with the allowed properties
---```lua
---  Table.new({a = 3, d = 6, b = 4, c = 5}):pick('a', 'b') --> {a = 3, b = 4}
---```
---@see Table_t.pluck  # return value of key in a table of tables
---@see Table_t.where  # return filtered sub-tables where condition is true
---@param ... string|integer
---@return Table_t
function Table:pick(...)
    local props = Table.new({...}):flatten()
    local res = Table.new({})
    props:each(function(k)
        if self[k] then
            if type(k) == "number" then
                res:insert(self[k])
            else
                res[k] = self[k]
            end
        end
    end)
    return res
end

---Opposite of filtering
---Returns elements that are falsy
---@generic T, K: string|number, V: any
---@param func fun(val: V, key: K, acc: T): boolean
---@return Table_t
function Table:reject(func)
    assert_t(func, "function")
    local res = Table.new({})
    self:each(function(v, k, acc)
        if not func(v, k, acc) then
            if type(k) == "number" then
                res:insert(v)
            else
                res[k] = v
            end
        end
    end)
    return res
end

---Return a copy of the table without the blacklisted properties
---@param ... table
---@return Table_t
function Table:omit(...)
    local props = Table.new({...}):flatten()
    local res = Table.new({})
    self:each(function(_v, k)
        if not props:contains(k) then
            res[k] = self[k]
        end
    end)
    return res
end

---Convenient `map` to fetch a property. Should be a table of tables
---```lua
---  Table.new({{a = 3, d = 6}, {b = 4, a = 5}}):pick('a') --> {3, 5}
---```
---@see Table_t.pick   # return table with allow properties
---@see Table_t.where  # return filtered sub-tables where condition is true
---@param key string|number
---@return Table_t
function Table:pluck(key)
    local found = Table.new({})
    self:each(function(val)
        found:insert(val[key])
    end)
    return found
end

-- TODO: which to use?

---Returns a unique set of the table. It only operates on the indexed keys.
---@param func? fun(v: any): any mutate values if provided and returns not nil.
---@return self
function Table:unique(func)
    if type(func) ~= "function" then
        func = nil
    end
    func = func or function(v)
        return v
    end
    local ret = Table.new()
    local seen = Table.new()
    for _, v in ipairs(self) do
        v = func(v) or v
        if not seen[v] then
            ret:insert(v)
        end
        seen[v] = true
    end
    return ret
end

---
---@param sorted? boolean
---@return self
function Table:uniq(sorted)
    local ret = Table.new({})
    local seen = Table.new({})
    self:each(function(v, k)
        if (sorted and (k == 1 or seen[#seen] ~= v)) or (not seen:contains(v)) then
            seen:insert(v)
            ret:insert(self[k])
        end
    end)

    return ret
end

---Return a reversed the table. Note that it only works on the numeric indices.
---@return self
function Table:reverse()
    local reversed = Table.new()
    local item_count = #self
    for k, v in pairs(self) do
        if type(k) == "number" then
            reversed[item_count + 1 - k] = v
        else
            reversed[k] = v
        end
    end
    return reversed
end

Table.rev = Table.reverse

math.randomseed(os.time())

---Shufle a table, returning a new
---@return self
function Table:shuffle()
    local ret = Table.new(self)
    local iterations = #ret
    local j
    for i = iterations, 2, -1 do
        j = math.random(i)
        ret[i], ret[j] = ret[j], ret[i]
    end
    return ret
end

---Returns parts of the table between first and last indices.
---It does not take the named keys into account.
---Indices can be negative.
---@param first? number
---@param last? number
---@param step? number the step between each index
---@return self
function Table:slice(first, last, step)
    local size = self:size()
    first = first and F.if_expr(first < 0, size + first + 1, first) or 1
    last = last and F.if_expr(last < 0, size + last + 1, last) or size
    step = step or 1
    if step == 1 then
        return Table.new({unpack(self, first, last)})
    end
    local sliced = Table.new({})
    last = last or #self
    for i = first, last, step do
        sliced[#sliced+1] = self[i]
    end
    return sliced
end

---Returns a table containing chunks of the given table by chunk size.{{{
---## Example
---```lua
---  local t = _c{11, 22, 3, 4, 5, 6, 7, 8, a=9, b=10}
---  local chunks = t:chunk(3)
---  for _, chunk in ipairs(chunks) do
---      print(table.concat(chunk, ", "))
---      --- prints: 1=11, 2=22, 3=3
---      ---         1=4, 2=5, 3=6
---      ---         1=7, 2=8, a=9
---      ---         b=10
---  end
---```
---@param size number
---@return self
function Table:chunk(size)
    if size == 0 then
        return self:deep_copy()
    end
    local ret = Table.new()
    local cur_chunk = 1
    local cur_size = 0
    for k, v in pairs(self) do
        cur_size = cur_size + 1
        if cur_size > size then
            cur_chunk = cur_chunk + 1
            cur_size = 1
        end
        ret[cur_chunk] = ret[cur_chunk] or Table.new()
        if type(k) == "number" then
            local key = k - ((cur_chunk - 1) * size)
            ret[cur_chunk][key] = v
        else
            ret[cur_chunk][k] = v
        end
    end
    return ret
end

---Get the first element of an array.
---If `n` is given, return indices 1-n
---@param n? integer
---@return any
function Table:first(n)
    if not n then
        return self[1]
    end
    return self:slice(1, n)
end

---Returns all but the first entry of the table
---If `n` is given, return the rest `n` entries
function Table:rest(start)
    return self:slice((start and start + 1) or 2)
end

---Return all but last entry of the table
---If `n` is given, the last index - `n` will be returned
function Table:initial(stop)
    return self:slice(1, self:size() - (stop or 1))
end

---Return last entry of the table
---If `n` is given, the last `n` elements will be returend
function Table:last(n)
    if not n then
        return self[self:size()]
    end
    return self:slice(self:size() - n + 1, self:size())
end

---Sorts list elements in a given order and returns a new `Table`.
---@param fn? fun(a: any, b: any):boolean
---@return self
function Table:sort(fn)
    return self:exec(function(tbl)
        self.__super.sort(tbl, fn)
        return tbl
    end)
end

---Get the result of the difference of the given tables
---@param ... table
---@return Table_t
function Table:diff(...)
    local t = Table.new({...}):flatten(true)
    return self:filter(function(val)
        return not t:contains(val)
    end)
end

---Return a table containing all shared items
---@param ... table
---@return Table_t
function Table:intersection(...)
    local t = Table.new({...})
    return self:unique():filter(function(v)
        return t:all(function(o)
            if type(o) == "table" then
                return Table.new(o):indexof(v) >= 1
            end
            return false
        end)
    end)
end

---Return a table containing the union: each unique element from all of the tables
---@param ... table
---@return Table_t
function Table:union(...)
    return Table.new({self, ...}):flatten(true):uniq()
end

---
---@param ... table
---@return Table_t
function Table:zip(...)
    local args = Table.new({self, ...})
    local len = args:map(function(v) return #v end):max()
    local res = Table.new({})

    for i = 1, len, 1 do
        -- res[i] = args:pluck(i)
        res:insert(args:pluck(i))
    end

    return res
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Returns the Table if the v condition is true. Otherwise returns an empty Table.
---@param v boolean
---@return self
function Table:when(v)
    return v and self or Table.new({})
end

---Clear the existing table. All values become `nil`
function Table:clear()
    self:map(function(_v)
        return nil
    end)
end

---Clone a table
---@return Table_t
function Table:clone()
    return self:fold(function(acc, v, k)
        acc[k] = v
        return acc
    end, Table.new({}))
end

---Deep clone a table
---@return Table_t
function Table:deep_clone()
    return self:fold(function(acc, v, k)
        if type(v) == "table" then
            acc[k] = Table.new(v):deep_clone()
        else
            acc[k] = v
        end
        return acc
    end, Table.new({}))
end

-- TODO: which to use?

---Deep copy a table
---@return Table_t
function Table:deep_copy()
    return Table.new(vim.deepcopy(self))
end

---Shallow copy a table
---@return Table_t
function Table:shallow_copy()
    local copy = {}
    setmetatable(copy, getmetatable(self))
    for k, v in next, self do
        copy[k] = v
    end
    return copy
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Try property access into a table
---```lua
---  Table.new({first = {sec = true}}):access('first.sec') == true
---  Table.new({first = {}}):access('first.sec') == nil
---  Table.new({first = {sec = true}}):access({"first", "sec"}) == true
---```
---@param path string|string[] Either a `.` separated string of table keys, or a list.
---@return Table_t?
function Table:access(path)
    local new = self
    local keys = type(path) == "table" and path or vim.split(path, ".", {plain = true})

    for _, k in ipairs(keys) do
        new = new[k]
        if not new then
            return nil
        end
    end
    return new
end

---Set a value in a table in place,
---creating all missing intermediate tables in the table path.
---```lua
---  Table.new({}):set('first.sec', true)
---```
---@param path string|string[] Either a `.` separated string of table keys, or a list.
---@param value any
function Table:set(path, value)
    local new = self
    local keys = type(path) == "table" and path or vim.split(path, ".", {plain = true})

    for i = 1, #keys - 1 do
        local k = keys[i]
        if not new[k] then
            new[k] = {}
        end
        new = new[k]
    end

    new[keys[#keys]] = value
end

---Ensure that the table path is a valid in `tbl`
---@param path string|string[] Either a `.` separated string of table keys, or a list.
function Table:ensure(path)
    local keys = type(path) == "table" and path or vim.split(path, ".", {plain = true})

    if not self:access(keys) then
        self:set(keys, {})
    end
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---`pairs` iterator
---@generic K, V
---@return fun(table: table<K, V>, index?: K): K, V
---@return Table_t
function Table:iter()
    return pairs(self)
end

---`ipairs` iterator
---@generic V
---@return fun(table: V[], i?: integer): integer, V # iterator
---@return Table_t # invariant state
---@return integer i # initial value
function Table:iteri()
    return ipairs(self)
end

---Enumerate a table sorted by its keys, returns an iterator
---@generic K, V
---@return fun(table: table<K, V>, index?: K): K, V
---@return Table_t
function Table:spairs()
    return pairs(self:sort())
end

---Reverse `ipairs` iterator
---@generic table, V
---@return fun(table: V[], i?: integer): integer, V iterator
---@return Table_t # invariant state
---@return integer i # initial value
function Table:ripairs()
    return ripairs(self)
end

---Inverse `ipairs` iterator
---Skips keys that are numbers, returning only dictionary values
---@generic V, K
---@return fun(table: table<K, V>, index?: K): K, V
---@return Table_t
---@return nil
function Table:kpairs()
    return kpairs(self)
end

---Convert a table into a key, value table of tables
---@return Table_t
function Table:kv_pairs()
    return self:map(function(v, k)
        return {v, k}
    end)
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Call a method (arguments are allowed) on all table elements
---@param func fun(...: any): any?
---@return Table_t
function Table:invoke(func, ...)
    local func_l, args = func, {...}
    if type(func) == "string" then
        func_l = function(val)
            return val[func](val, unpack(args))
        end
    end
    return self:map(function(val)
        return func_l(val, unpack(args))
    end)
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- NOTE: This is more like an fmap
-- ---Filters the table if the function returns true.
-- ---@param func fun(v: any): boolean
-- ---@return self
-- function Table:filter_alt(func)
--     assert_t(func, "function")
--     local ret = Table.new({})
--     local cur_index = 0
--     for k, v in pairs(self) do
--         local ok, new_val = func(v)
--         if ok then
--             if type(k) == "number" then
--                 cur_index = cur_index + 1
--                 ret[cur_index] = new_val or v
--             else
--                 ret[k] = new_val or v
--             end
--         end
--     end
--     return ret
-- end

M.new = Table.new
M.range = Table.range
M.fill = Table.fill
M.zeros = Table.zeros
M.ones = Table.ones
M.is_instance = Table.is_instance
M.autoviv = Table.autoviv
M.pack = Table.pack

_G._j = Table.new

Table.__call = Table.new

return setmetatable(M, {
    __call = function(_self, ...)
        return Table.new(...)
    end,
})
