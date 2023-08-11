---@module 'usr.shared.F'
---@class Usr.Shared.F
local M = {}

local lazy = require("usr.lazy")
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'
local C = lazy.require("usr.shared.collection") ---@module 'usr.shared.collection'
-- local A = lazy.require("usr.shared.utils.async") ---@module 'usr.shared.utils.async'

local uv = vim.loop

M.op = lazy.require("usr.shared.F.op") ---@module 'usr.shared.F.op'
M.is = lazy.require("usr.shared.F.is") ---@module 'usr.shared.F.is'

-- |   Function  |   Short Demonstration of Idea  |    In English    |  In English 2  |   Alias   |
-- |=============|================================|==================|================|===========|
-- | F.if_expr   | ternary helper                 | if else truthy   | truthy and or  | ife_then  |
-- | F.ife_nil   | cond == NULL  ? want : default | if else nil      | nil else       |           |
-- | F.ife_nnil  | cond != NULL  ? want : default | if else not nil  | not nil else   |           |
-- | F.ife_true  | cond == true  ? want : default | if else true     | true else      |           |
-- | F.ife_false | cond == false ? want : default | if else false    | false else     |           |
-- | F.if_then   |          cond ? want : cond    | if truthy then   | truthy and     |           |
-- | F.ifn_then  |         !cond ? want : cond    | if not then      | not truthy and |           |
-- | F.ift_then  | cond == true  ? want : cond    | if true then     | true and then  | true_and  |
-- | F.iff_then  | cond == false ? want : cond    | if false then    | false and then | false_and |
-- | F.unwrap_or | cond == NULL  ? want : cond    | if nil then      | nil and then   |           |
-- | F.true_or   | cond == true  ? cond : other   | this if true or  | true or        |           |
-- | F.false_or  | cond == false ? cond : other   | this if false or | false or       |           |
-- | F.if_nil    | [1, 2].find(|v| => v != NULL)  | find non-null    |                |           |
-- | F.if_true   | [1, 2].any(|v| => v == true)   | check if any T   |                |           |
-- | F.if_false  | [1, 2].any(|v| => v == false)  | check if any F   |                |           |

---## ternary
---Ternary helper for when `if_t` might be a falsy value, and you can't
---compose the expression as `cond and if_t or if_f`.
---
---The outcomes may be given as lists where the first index is a callable object,
---and the subsequent elements are args to be passed to the callable if the outcome
---is to be evaluated.
---### Example:
---```c
---  // c
---  cond ? "yes" : "no"
---  cond ? foo(1, 2) : bar(3)
---```
---```lua
---  -- lua
---  F.tern(cond, "yes", "no")
---  F.tern(cond, { foo, 1, 2 }, { bar, 3 })
---```
--- ***
---@generic T, V
---@param cond? any|boolean|fun():boolean statement to be tested
---@param if_t T return value if `cond` is truthy
---@param if_f V return value if `cond` is not truthy
---@param simple? boolean never treat `if_t` and `if_f` as arg lists
---@return unknown
function M.tern(cond, if_t, if_f, simple)
    if cond then
        if not simple and type(if_t) == "table" and vim.is_callable(if_t[1]) then
            return if_t[1](C.vec_select(if_t, 2))
        end
        return if_t
    else
        if not simple and type(if_f) == "table" and vim.is_callable(if_f[1]) then
            return if_f[1](C.vec_select(if_f, 2))
        end
        return if_f
    end
end

---## ternary (simple)
---Return a value based on two values
---Equivalent to a ternary.
--- ***
---### Example:
---```lua
---  local r = 4
---  local res = F.if_expr(a < 5, {a = 1}, {a = 2}) -- a < 5 ? {a = 1} : {a = 2}
---  assert(res.a == 1)
---```
--- ***
---@generic T, V
---@param cond any statement to be tested
---@param if_t T return value if `cond` is truthy
---@param if_f V return value if `cond` is not truthy
---@return T | V
function M.if_expr(cond, if_t, if_f)
    return M.tern(cond, if_t, if_f, true)
end

M.ife_then = M.if_expr

---## if else nil
---Equivalent to a ternary that checks if the value is `nil`.
---### Overview:
---```c
---  char* x = cond == NULL ? "want" : "default"
---```
---```lua
---  if cond == nil then want else default end
---  F.if_expr(cond == nil, want, default)
---  F.ife_nil(cond, want, default)
---```
--- ***
---### Example:
---```lua
---  local v = F.ife_nil(false, {a = 1}, {a = 2})
---  assert(v.a == 2)
---
---  local j
---  assert(F.ife_nil(j, {a = 1}, {a = 2}).a == 1)
---```
--- ***
---@generic T, V
---@param cond any value to check if `nil`
---@param if_n T value to return if `cond` is `nil`
---@param if_not_n V value to return if `cond` is `not nil`
---@return T | V
function M.ife_nil(cond, if_n, if_not_n)
    return M.if_expr(cond == nil, if_n, if_not_n)
end

---## if else not nil
---Equivalent to a ternary that checks if the value is `not nil`.
---### Overview:
---```c
---  char* x = cond != NULL ? "want" : "default"
---```
---```lua
---  if cond ~= nil then want else default end
---  F.if_expr(cond ~= nil, want, default)
---  F.ife_nnil(cond, want, default)
---```
--- ***
---### Example:
---```lua
---  local v = F.ife_nnil(false, {a = 1}, {a = 2})
---  assert(v.a == 1)
---
---  local j
---  assert(F.ife_nnil(j, {a = 1}, {a = 2}).a == 2)
---```
--- ***
---@generic T, V
---@param cond any value to check if `not nil`
---@param if_not_n T value to return if `cond` is `not nil`
---@param if_not_not_n V value to return if `cond` is not `not nil`
---@return T | V
function M.ife_nnil(cond, if_not_n, if_not_not_n)
    return M.if_expr(cond ~= nil, if_not_n, if_not_not_n)
end

---## if else true
---Equivalent to a ternary that explicitly checks if the value is `true`.
---### Overview:
---```c
---  char* x = cond == true ? "want" : "default"
---```
---```lua
---  if cond == true then want else default end
---  M.if_expr(cond == true, want, default)
---  F.ife_true(cond, want, default)
---```
--- ***
---### Example:
---```lua
---  local v = F.ife_true(false, {a = 1}, {a = 2})
---  assert(v.a == 2)
---```
--- ***
---@generic T, V
---@param cond any value to check if `true`
---@param if_t T value to return if `cond` is `true`
---@param if_not_t V value to return if `cond` is `not true`
---@return T | V
function M.ife_true(cond, if_t, if_not_t)
    return M.if_expr(cond == true, if_t, if_not_t)
end

---## if else false
---Equivalent to a ternary that checks if the value is `false`.
---### Overview:
---```c
---  char* x = cond == false ? "want" : "default"
---```
---```lua
---  if cond == false then want else default end
---  F.if_expr(cond == false, want, default)
---  F.ife_false(cond, want, default)
---```
--- ***
---### Example:
---```lua
---  local v = F.ife_false(false, {a = 1}, {a = 2})
---  assert(v.a == 1)
---```
--- ***
---@generic T, V
---@param cond any value to check if `false`
---@param if_f T value to return if `cond` is `false`
---@param if_not_f V value to return if `cond` is `not false`
---@return T | V
function M.ife_false(cond, if_f, if_not_f)
    return M.if_expr(cond == false, if_f, if_not_f)
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---## if then
---Return another value if `val` is truthy.
---Basically a default-value-giver when you're testing for the truthiness of the value.
---### Overview:
---```c
---  char* x = cond ? "want" : cond
---```
---```lua
---  if not this then want else this end
---  F.if_expr(val, other, val)
---  F.if_then(val, other)
---```
--- ***
---### Example:
---```lua
---  local v = F.ift_then({a = 1}, {a = 2})
---  assert(v.a == 2)
---```
--- ***
---@generic T, V
---@param val T value to check if truthy
---@param thenv V default value to return if `val` is truthy
---@return T|V
function M.if_then(val, thenv)
    return M.if_expr(val, thenv, val)
end

---## if not then
---Return another value if `val` is `not true`.
---Basically a default-value-giver when you're testing for the negation of the value.
---### Overview:
---```c
---  char* x = !cond ? "want" : cond
---```
---```lua
---  if not this then want else this end
---  F.if_expr(not val, other, val)
---  F.ifn_then(val, other)
---```
--- ***
---### Example:
---```lua
---  local v = F.ifn_then({a = 1}, {a = 2})
---  assert(v.a == 1)
---```
--- ***
---@generic T, V
---@param val T value to check if not truthy
---@param thenv V default value to return if `val` is not truthy
---@return T|V
function M.ifn_then(val, thenv)
    return M.if_expr(not val, thenv, val)
end

---## if true then
---Return another value if `val` is `true`.
---Differs from `F.if_then` by checking for explicit `true`, not truthiness.
---Basically a default-value-giver when you're testing for an explicit `true`.
---### Overview:
---```c
---  char* x = cond == true ? "want" : cond
---```
---```lua
---  if this == true then other else this end
---  F.if_expr(val == true, other, val)
---  F.if_then(val == true, other)
---  F.ift_then(val, other)
---  F.true_and()                              -- alt name for this func
---```
--- ***
---### Example:
---```lua
---  local v = F.ift_then({a = 1}, {a = 2})
---  assert(v.a == 1)
---```
--- ***
---@generic T, V
---@param val T value to check if `true`
---@param other V other value to return if `val` is `true`
---@return T | V
function M.ift_then(val, other)
    return M.ife_true(val, other, val)
end

---## if false then
---Return another value if `val` is `false`.
---Differs from `F.ifn_then` by checking for explicit `false`, not non-truthiness.
---Basically a default-value-giver when you're testing for an explicit `false`.
---### Overview:
---```c
---  char* x = cond == false ? "want" : cond
---```
---```lua
---  if this == false then other else this end
---  F.if_expr(val == false, other, val)
---  F.if_then(val == false, other)
---  F.iff_then(val, other)
---  F.false_and()                              -- alt name for this func
---```
--- ***
---### Example:
---```lua
---  local v = F.iff_then({a = 1}, {a = 2})
---  assert(v.a == 1)
---```
--- ***
---@generic T, V
---@param val T value to check if `false`
---@param other V other value to return if `val` is `false`
---@return T | V
function M.iff_then(val, other)
    return M.ife_false(val, other, val)
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---## this if not nil or
---Return another value if `val` is `nil`.
---Basically a standard default-value-giver.
---### Overview:
---```c
---  char* x = cond == NULL ? "want" : cond
---```
---```lua
---  if this == nil then other else this end
---  F.if_expr(val == nil, other, val)
---  F.ife_nil(val, other, val)
---  F.if_then(val == nil, other)
---  F.unwrap_or(val, other)
---```
--- ***
---### Example:
---```lua
---  local v = F.unwrap_or({a = 1}, {a = 2})
---  assert(v.a == 1)
---
---  local j
---  assert(F.unwrap_or(j, {a = 1}).a == 1)
---```
--- ***
---@generic T, V
---@param val T value to check if `nil`
---@param default V default value to return if `val` is `nil`
---@return T | V
function M.unwrap_or(val, default)
    if type(val) ~= "table" then
        return M.ife_nil(val, default, val)
    end
    val = vim.deepcopy(val or {})
    for k, v in pairs(default) do
        if val[k] == nil then
            val[k] = v
        end
    end
    return val
end

M.nnil_or = M.unwrap_or

---## this if true or
---Return `val` if `val` is `true`, else another.
---Inverse of `F.ift_then` (a.k.a. `F.true_and`)
---### Overview:
---```c
---  char* x = cond == true ? cond : "other"
---```
---```lua
---  if val == true then val else other end
---  F.if_expr(val == true, val, other)
---  F.ife_true(val, val, other)
---  F.true_or(val, other)
---```
--- ***
---@generic T, V
---@param val T value to check if `true`
---@param other V other value to return if `val` isn't `true`
---@return T | V
function M.true_or(val, other)
    return M.ife_true(val, val, other)
end

---## this if false or
---Return `val` if `val` is `false`, else another.
---Inverse of `F.iff_then` (a.k.a. `F.false_and`)
---### Overview:
---```c
---  char* x = cond == false ? cond : "other"
---```
---```lua
---  if val == false then val else other end
---  F.if_expr(val == false, val, other)
---  F.ife_false(val, val, other)
---```
--- ***
---@generic T, V
---@param val T value to check if `false`
---@param other V other value to return if `val` isn't `false`
---@return T | V
function M.false_or(val, other)
    return M.ife_false(val, val, other)
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---## if nil
---Returns the first argument which is not `nil`.
---If all arguments are `nil`, returns `nil`.
--- ***
---@generic T : any
---@param ... T arguments to check if `nil`
---@return T
function M.if_nil(...)
    local nargs = select("#", ...)
    for i = 1, nargs do
        local v = select(i, ...)
        if v ~= nil then
            return v
        end
    end
    return nil
end

---## if true
---Returns `true` if any arguments are `true`, else `false`
--- ***
---@param ... any arguments to check if `true`
---@return boolean
function M.if_true(...)
    return C.any({...}, function(v)
        return v == true
    end)
end

---## if true
---Returns `true` if any arguments are `false`, else `false`
---@param ... any arguments to check if `false`
---@return boolean
function M.if_false(...)
    return C.any({...}, function(v)
        return v == false
    end)
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Ternary that checks if `item` is falsy
---@generic T, V
---@param item string|table|boolean|number item to check if empty
---@param if_t T return value if `cond` is falsy
---@param if_f V return value if `cond` is not falsy
---@return T | V
function M.ifis_falsy(item, if_t, if_f)
    return M.tern(M.is.falsy(item), if_t, if_f)
end

---Ternary that checks if `item` is truthy
---@generic T, V
---@param item string|table|boolean|number item to check if empty
---@param if_t T return value if `cond` is truthy
---@param if_f V return value if `cond` is not truthy
---@return T | V
function M.ifis_truthy(item, if_t, if_f)
    return M.tern(M.is.truthy(item), if_t, if_f)
end

---Ternary that checks if `item` is empty
---@generic T, V
---@param item any item to check if empty
---@param if_t T return value if `cond` is empty
---@param if_f V return value if `cond` is not empty
---@return T | V
function M.ifis_empty(item, if_t, if_f)
    return M.tern(M.is.empty(item), if_t, if_f)
end

---Ternary that checks if `type(item)` is `table`
---@generic T, V
---@param tbl any item to check if is a list
---@param if_t T return value if `type(cond)` is `table`
---@param if_f V return value if `type(cond)` is not `table`
---@return T | V
function M.ifis_tbl(tbl, if_t, if_f)
    return M.tern(M.is.tbl(tbl), if_t, if_f)
end

---Ternary that checks if `item` is a hashmap
---@generic T, V
---@param hash any item to check if is a hashmap
---@param if_t T return value if `cond` is a hashmap
---@param if_f V return value if `cond` is not a hashmap
---@return T | V
function M.ifis_hash(hash, if_t, if_f)
    return M.tern(M.is.hash(hash), if_t, if_f)
end

---Ternary that checks if `item` is a list
---@generic T, V
---@param list any item to check if is a list
---@param if_t T return value if `cond` is a list
---@param if_f V return value if `cond` is not a list
---@return T | V
function M.ifis_list(list, if_t, if_f)
    return M.tern(M.is.list(list), if_t, if_f)
end

---Ternary that checks if `item` is an array
---@generic T, V
---@param arr any item to check if is an array
---@param if_t T return value if `cond` is an array
---@param if_f V return value if `cond` is not an array
---@return T | V
function M.ifis_array(arr, if_t, if_f)
    return M.tern(M.is.array(arr), if_t, if_f)
end

---Ternary that checks if `type(item)` is `string`
---@generic T, V
---@param str any item to check if type `string`
---@param if_t T return value if `type(cond)` is `string`
---@param if_f V return value if `type(cond)` is not `string`
---@return T | V
function M.ifis_str(str, if_t, if_f)
    return M.tern(M.is.str(str), if_t, if_f)
end

---Ternary that checks if `type(item)` is `number`
---@generic T, V
---@param num any item to check if type `number`
---@param if_t T return value if `type(cond)` is `number`
---@param if_f V return value if `type(cond)` is not `number`
---@return T | V
function M.ifis_num(num, if_t, if_f)
    return M.tern(M.is.num(num), if_t, if_f)
end

---Ternary that checks if `item` is an integer
---@generic T, V
---@param num any item to check if an integer
---@param if_t T return value if `cond` is an integer
---@param if_f V return value if `cond` is not an integer
---@return T | V
function M.ifis_int(num, if_t, if_f)
    return M.tern(M.is.int(num), if_t, if_f)
end

---Ternary that checks if `item` is nan
---@generic T, V
---@param num any item to check if nan
---@param if_t T return value if `cond` is nan
---@param if_f V return value if `cond` is not nan
---@return T | V
function M.ifis_nan(num, if_t, if_f)
    return M.tern(M.is.nan(num), if_t, if_f)
end

---Ternary that checks if `item` is a finite number
---@generic T, V
---@param num any item to check if a finite number
---@param if_t T return value if `cond` is a finite number
---@param if_f V return value if `cond` is not a finite number
---@return T | V
function M.ifis_finite(num, if_t, if_f)
    return M.tern(M.is.finite(num), if_t, if_f)
end

---Ternary that checks if `type(item)` is `function`
---@generic T, V
---@param func any item to check if callable
---@param if_t T return value if `type(cond)` is `function`
---@param if_f V return value if `type(cond)` is not `function`
---@return T | V
function M.ifis_fn(func, if_t, if_f)
    return M.tern(M.is.fn(func), if_t, if_f)
end

---Ternary that checks if `item` is callable
---@generic T, V
---@param func any item to check if callable
---@param if_t T return value if `cond` is callable
---@param if_f V return value if `cond` is not callable
---@return T | V
function M.ifis_callable(func, if_t, if_f)
    return M.tern(M.is.callable(func), if_t, if_f)
end

---Ternary that checks if `type(item)` is `bool`
---@generic T, V
---@param bool any item to check if type is bool
---@param if_t T return value if `type(cond)` is `bool`
---@param if_f V return value if `type(cond)` is not `bool`
---@return T | V
function M.ifis_bool(bool, if_t, if_f)
    return M.tern(M.is.bool(bool), if_t, if_f)
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Identity function
---@generic R
---@param ... R
---@return R ... #same arguments that were passed to the function
function M.id(...)
    return ...
end

---No-operation function
function M.noop()
end

---Convert a type to a boolean
---@param val any
---@return boolean
function M.tobool(val)
    return not not val
end

---Create a constant function which returns the initial value on every call
---@generic T
---@param value T constant value
---@return fun(): T
function M.const(value)
    return function()
        return value
    end
end

---Bind a function to some arguments and return a new function that can be called later
---Useful for setting up callbacks without anonymous functions
---### Overview:
---```lua
---  thunk(fn, A1)(A2) == fn(A1, A2)
---  assert(thunk(p, "1", "2")("3") == "1 2 3")
---```
--- ***
---@generic T1, T2, R
---@param func? ThunkFn<T1, T2, R> function to be called
---@param ... T1 arguments that are passed to `func`
---@return fun(...: T2): R fn function that will accept more arguments
function M.thunk(func, ...)
    local bound = {...}
    return function(...)
        return func and func(unpack(vim.list_extend(vim.list_extend({}, bound), {...})))
    end
end

---Similar to `thunk` except it is schedule wrapped
---@generic T1, T2, R
---@param func ThunkFn<T1, T2, R> function to be called
---@param ... T1 arguments that are passed to `func`
---@return fun(...: T2): R fn function that will accept more arguments
function M.sthunk(func, ...)
    local bound = {...}
    return function(...)
        local ibound = {...}
        return vim.schedule(function()
            func(unpack(vim.list_extend(vim.list_extend({}, bound), ibound)))
        end)
    end
end

---Like `thunk()`, but arguments passed to the thunk are ignored
---Overview: calling return is equivalent to `func(...: A1)`
---### Overview:
---```lua
---  ithunk(fn, A1)(A2) == fn(A1)
---  ithunk(p, "1", "2")("3")  --> "1 2"
---```
--- ***
---@generic T, R
---@param func? IThunkFn<T, R> function to be called
---@param ... T arguments that are passed to `func`
---@return fun(): R fn function that will not accept more arguments
function M.ithunk(func, ...)
    local bound = {...}
    return function()
        return func and func(unpack(bound))
    end
end

---Similar to `ithunk` except it is schedule wrapped
---@generic T, R
---@param func IThunkFn<T, R> function to be called
---@param ... T arguments that are passed to `func`
---@return fun(): R fn function that will not accept more arguments
function M.sithunk(func, ...)
    local bound = {...}
    return function()
        return vim.schedule(function()
            func(unpack(bound))
        end)
    end
end

---Same as `ithunk()`, except prefixed with a `pcall`
--- ***
---@generic T, R
---@param func IThunkFn<T, R> function to be called
---@param ... T arguments that are passed to `func`
---@return fun(): R fn function that will not accept more arguments
function M.pithunk(func, ...)
    return M.ithunk(pcall, func, ...)
end

---Bind a function to a table, allowing for self to be used, referencing the table.
---Optionally, bind arguments to the function to pre-fill them, also known as partial application.
---
---### Overview:
---```lua
---   bind(fn, {i = 22}, A1)(A2, A3)
---     => fn({i = 22} --[[@as self]], A2, A3, A1) -- becomes this
---```
--- ***
---### Example:
---```lua
---  local disp = function(self, echo) return ("%s: %s"):format(echo, self.arg) end
---  local bound = F.bind(disp, {arg = "this will echo"})
---  assert(bound("greetings") == 'greetings: this will echo')
---
---  bound = F.bind(disp, {arg = "this will echo"}, "second")
---  assert(bound() == 'second: this will echo')
---```
--- ***
---@generic C, T1, T2, R
---@param func BindFn<C, T1, T2, R> function to be called
---@param context C context passed to `func`
---@param ... T1 arguments that are passed to `func`
---@return fun(...: T2): R fn function that will accept more arguments
function M.bind(func, context, ...)
    local bound = {...}
    return function(...)
        -- return func(context, unpack(_j(bound):merge({...})))
        -- return func(context, unpack(vim.list_extend({...}, vim.list_extend({}, bound))))
        return func and func(context, unpack(vim.list_extend({...}, bound)))
    end
end

---Like `bind()`, except all later arguments are ignored.
---Calling returned function is equivalent to `fn(context, ...: A1)`.
---
---### Overview:
---```lua
---   ibind(fn, {i = 22}, A1)(A2, A3)
---     => fn({i = 22} --[[@as self]], A1) -- becomes this
---```
--- ***
---@generic C, T, R
---@param func IBindFn<C, T, R> function to be called
---@param context C context passed to `func`
---@param ... T arguments that are passed to `func`
---@return fun(): R fn function that will not accept more arguments
function M.ibind(func, context, ...)
    local bound = {...}
    return function()
        return func and func(context, unpack(bound))
    end
end

---Partially bind a function to arguments.
---Unlike bind, the optional arguments are what is referred to as `self`.
---
---### Overview:
---```lua
---   partial(fn, A1)({i = 1}, A2)
---     => fn({i = 1} --[[@as self]], A1, A2) -- becomes this
---```
--- ***
---### Example:
---```lua
---  local obj = {id = "tbl"}
---  local f = function(self, a1, a2, a3) return ("%s: %s):format(self.id, _j({a1, a2, a3}):concat('-')) end
---  obj.f = F.partial(f, 'abc', 'def')
---  assert(obj:f('ghi') == 'tbl: abc-def-ghi')
---
---  local disp = function(self, echo) return ("%s: %s"):format(echo, self.arg) end
---  local bound = F.partial(disp, 'greetings')
---  assert(bound({arg = "this will echo"}) == 'greetings: this will echo')
---```
--- ***
---@generic T1, T2, R
---@param func PartialFn<T1, T2, R> function to be called
---@param ... T1 arguments that are passed to `func`
---@return fun(self, ...: T2): R fn function that will accept more arguments
function M.partial(func, ...)
    local bound = {...}
    return function(self, ...)
        -- return func(self, unpack(_j(bound):merge({...})))
        return func(self, unpack(vim.list_extend(bound, {...})))
    end
end

---Like `partial`, except all later arguments
---(minus the first, i.e., what is passed becomes `self`) are ignored.
---
---### Overview:
---```lua
---   ipartial(fn, A1)({i = 1}, A2)
---     => fn({i = 1} --[[@as self]], A1) -- becomes this
---```
--- ***
---@generic T, R
---@param func PartialFn<T, R> function to be called
---@param ... T arguments that are passed to `func`
---@return fun(self): R fn function that will accept more arguments
function M.ipartial(func, ...)
    local bound = {...}
    return function(self)
        return func(self, unpack(bound))
    end
end

---Return the first func passed as an argument to the second
---### Overview:
---```lua
---   partial(fn, A1)({i = 1}, A2)
---     => fn({i = 1} --[[@as self]], A1, A2) -- becomes this
---```
--- ***
---### Example:
---```lua
---```
--- ***
---@generic T, R1, R2
---@param func WrapFn1<T, R1> function to be called
---@param wrapper WrapFn2<T, R1, R2>
---@return fun(...: T): R2 fn function that will accept more arguments
function M.wrap(func, wrapper)
    return M.partial(wrapper, func)
    -- return function(...)
    --     return wrapper(func, ...)
    -- end
end

---Fully apply arguments to a function.
---### Overview:
---```lua
---   partial(fn, A1)({i = 1}, A2)
---     => fn({i = 1} --[[@as self]], A1, A2) -- becomes this
---```
--- ***
---### Example:
---```lua
---```
function M.apply(func, ...)
    local params = C.pack(...)
    local count = params.n
    local offset = count - 1
    local packed = params[count]

    if type(packed) == "table" then
        params[count] = nil
        for index, item in pairs(packed) do
            if (type(index) == "number") then
                count = offset + index
                params[count] = item
            end
        end
    end

    return func(unpack(params, 1, count))
end

---Returns a negated function of the passed-in function
---@generic T, R, NotR
---@param func fun(...: T): R
---@return fun(...: T): NotR
function M.compliment(func)
    return function(...)
        return not func(...)
    end
end

M.negate = M.compliment

---Return a function with with arguments reversed.
---@generic T, R
---@param func FlipFn<T, R>
---@return fun(...: T): R
function M.flip(func)
    return function(...)
        return func(unpack(_j({...}):reverse()))
    end
end

---Return a function consisting of a list of functions,
---each consumes the return value of the function that follows.
---It is equivalent to the composing funcs of `f`, `g`, and `h` producing the function `f(g(h(...)))`.
---### Overview:
---```lua
---   partial(fn, A1)({i = 1}, A2)
---     => fn({i = 1} --[[@as self]], A1, A2) -- becomes this
---```
--- ***
---### Example:
---```lua
---```
--- ***
---@generic R
---@param ... (fun(...): R?)[]
---@return R?
function M.compose(...)
    local funcs = C.pack(...)
    return function(...)
        local argv = C.pack(...)
        for i = 1, funcs.n do
            argv = C.pack(funcs[i](unpack(argv, 1, argv.n)))
        end
        return unpack(argv, 1, argv.n)
    end

    -- return function(...)
    --     local args = {...}
    --     _j(funcs):reverse():each(function(fn)
    --         args = {fn(unpack(args))}
    --     end)
    --     return args[1]
    -- end
end

---Convenience function that pipes a value through a series of functions.
---In math terms, given some functions `f`, `g`, and `h` in that order, it returns `f(g(h(value)))`.
--- ***
---@generic R, T
---@param value T argument to all the functions
---@param ... (fun(val: T): R?)[] functions to call
---@return R? result result of the function composition
function M.pipe(value, ...)
    return M.compose(...)(value)
end

---Call a sequence of functions with the same argument.
---Returns a sequence of results.
--- ***
---@generic R, T
---@param value T argument to all the functions
---@param ... (fun(val: T): R?)[] functions to call
---@return R[] results list of results from the function calls
function M.juxtapose(value, ...)
    local res = {}
    local funcs = C.pack(...)
    for i = 1, funcs.n do
        res[i] = funcs[i](value)
    end
    return unpack(res)
end

-- -- Delays a function for the given number of milliseconds, and then calls
-- -- it with the arguments supplied.
-- M.delay = function(func, wait, args)
--     --  return set_timeout(function(){
--     --    return func.apply(null, args);
--     --  }, wait);
-- end

function M.delay(func, ms, ...)
    local args, ret = {...}
    local timer = uv.new_timer()
    if timer then
        timer:start(ms, 0, function()
            timer:close()
            ret = F.apply(func, args)
            -- ret = func(unpack(args))
        end)
    end
    return ret
end

---Calls `func` with the given `value`, returning the original `value`.
---Purpose: 'tap into' a method chain to perform operations on intermediate results within the chain.
---***
---@generic T
---@param value T
---@param func fun(a: T): any?
---@return T
function M.tap(value, func)
    func(value)
    return value
end

---Return an iterator which repeatedly applies `func` onto `args`.
---Yields x, then `f(x)`, then `f(f(x))`, continuously, as long ias the function is called.
---@generic T, R
---@param func fun(a: T): R
---@param args T arguments to `func`
---@return fun(): R
function M.iter(func, args)
    return function()
        args = func(args)
        return args
    end
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Run `func` `n` times.
---Collect results of each run and return as an array.
---@generic T, R
---@param n integer number of times `func` should be called
---@param func fun(n: integer, ...: T): R
---@param ... T arguments passed to `func`
---@return R[]
function M.times(n, func, ...)
    local res = {}
    for i = 1, n do
        res[i] = func(i, ...)
    end
    return res
end

---Return a function that can be called one time.
---There is a key `reset` on the returned value, which will reset the 'once' call
--- ***
---@generic T : ..., R
---@param func fun(a?: T): R? function to call once
---@return {__call: fun(a?: T): R?, reset: fun()}
function M.once(func)
    local called = false
    return setmetatable(
        {
            reset = function()
                called = false
            end,
        },
        {
            __call = function(_, ...)
                if not called then
                    called = true
                    return func(...)
                end
            end,
        }
    )
end

---Return a version of `func` that will only be executed up to but not including the `n`th call
---Next calls will keep yielding the results of the `n`-th call.
--- ***
---@generic T, R
---@param n integer time to start running function
---@param func fun(...: T): R? function to call once
---@return fun(...: T): R?
function M.before(n, func)
    local internal = 0
    local args = {}
    return function(...)
        internal = internal + 1
        if internal <= (n - 1) then
            args = {...}
        end
        return func(unpack(args))
    end
end

---Return a function that will only be executed on and after the `n`th call
---@generic T, R
---@param n integer time to start running function
---@param func fun(...: T): R? function to call once
---@return fun(...: T): R?
function M.after(n, func)
    local limit, internal = n, 0
    return function(...)
        internal = internal + 1
        if internal >= limit then
            return func(...)
        end
    end
end

M.cache = {
    ["local"] = {},
    ["global"] = {},
    ["field"] = {},
    ["method"] = {},
    ["func"] = {},
    [""] = {},
}

---Return cached function value for next call
---Might be overkill really
---@generic T : ..., R
---@param func fun(a: T): R function that will take at least one arg
---@return fun(a: T): R function with at least one arg, used as the key
function M.memoize(func)
    return function(...)
        local d1 = debug.getinfo(1, "n")
        local d2 = debug.getinfo(2)
        if d1.namewhat == "" then
            d1.namewhat = "func"
        end
        if not M.cache[d1.namewhat][d2.short_src] then
            M.cache[d1.namewhat][d2.short_src] = {}
        end
        if not M.cache[d1.namewhat][d2.short_src][d1.name] then
            M.cache[d1.namewhat][d2.short_src][d1.name] = {}
        end
        local res = M.cache[d1.namewhat][d2.short_src][d1.name][{...}]
        if res == nil then
            res = func(...)
            M.cache[d1.namewhat][d2.short_src][d1.name][{...}] = res or "nil"
        end
        return res
    end

    --     local cache = {}
    --     return function(...)
    --         local res = cache[...]
    --         if res == nil then
    --             res = func(...)
    --             cache[...] = res
    --         end
    --         return res
    --     end
end

---Run a function one time during the vim session
--- ***
---@generic T: ..., R
---@param func fun(a: T): R function to call once
---@return fun(a: T): R
function M.onceg(func)
    return M.memoize(func)
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Use in combination with pcall.
---@generic T
---@param status boolean status from `pcall`
---@param ... `T`
---@return T ...
function M.ok_or_nil(status, ...)
    if not status then
        return
    end
    return ...
end

---Nil `pcall`. If `pcall` succeeds, return result of `func`, else `nil`.
---Displays an error on failure, but doesn't halt execution.
--- ***
---### Example:
---```lua
---  local m = F.npcall(require, 'ufo') -- if `m` is anything, it is the `ufo` module
---  if not m then
---    return
---  end
---```
--- ***
---@generic V, R
---@generic T : fun()
---@param func T<fun(v: V): `R`?> function to call
---@param ... V arguments to function
---@return R?
function M.npcall(func, ...)
    return M.ok_or_niln(pcall(func, ...))
end

---Wrap a function to return `nil` if it fails, otherwise the value
--- ***
---### Example:
---```lua
---  require('usr.shared').F.nil_wrap(require)('ufo')
---```
--- ***
---@generic T : fun()
---@param func T function to wrap with a call
---@return T<fun(v: any): any?>
function M.nil_wrap(func)
    return function(...)
        return M.npcall(func, ...)
    end
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Use in combination with pcall.
---Mainly used for requiring possibly missing modules cause it sends notifications
---@generic T
---@param status boolean status from `pcall`
---@param ... T
---@return T ...
function M.ok_or_niln(status, ...)
    if not status then
        local args = _t({...})
        local msg = args:concat("\n"):split("\n")
        local mod = msg[1]:match("module '(%w.*)'")
        C.vec_insert(
            msg,
            ("File     : %s"):format(log.__FILE__()),
            ("Traceback: %s"):format(log.__TRACEBACK__()),
            ""
        )
        vim.schedule(function()
            log.err(msg, {
                title = ('Failed to require("%s")'):format(mod),
                once = true,
            })
        end)
        return
    end
    return ...
end

-- ---@overload fun(func: fun(...<T:unknown>):<R:any>, ...<T:unknown>): boolean, <R:any>

---Call the given function and use `vim.notify` to notify of any errors
---this function is a wrapper around `xpcall` which allows having a single
---error handler for all errors
--- ***
---@generic T: ..., R: any
---@param msg string|nil|fun(...: T): R
---@param func fun(...: T): R Function to be called
---@param ... T Arguments that are passed to `func`
---@return boolean, R
---@overload fun(func: fun(...: T): R, ...: T): boolean, R
function M.xpcall(msg, func, ...)
    local args = {...}
    if type(msg) == "function" then
        func, args, msg = msg, {func, unpack(args)}, nil
    end

    local f = log.__FILE__()
    local tb = log.__TRACEBACK__()

    return xpcall(
        func,
        function(err)
            local errsp = err:split("\n")
            local title = M.unwrap_or(msg, errsp[1])
            local body = M.if_expr(msg == nil, _t(errsp):slice(2), _t(errsp))
            C.vec_insert(body, "", ("File     : %s"):format(f), ("Traceback: %s"):format(tb), "")

            vim.schedule(function()
                log.err(body, {title = title, once = true})
            end)
        end,
        unpack(args)
    )
end

return M
