---@module 'usr.shared.functional'
local M = {}

local lazy = require("usr.lazy")
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'
local C = lazy.require("usr.shared.collection") ---@module 'usr.shared.collection'

--- ***
---## ternary
---Ternary helper for when `if_t` might be a falsy value, and you can't
---compose the expression as `cond and if_t or if_f`.
---
---The outcomes may be given as lists where the first index is a callable object,
---and the subsequent elements are args to be passed to the callable if the outcome
---is to be evaluated.
---
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
---@generic T, V
---@param cond? any|boolean|fun():boolean Statement to be tested
---@param if_t T Return if cond is truthy
---@param if_f V Return if cond is not truthy
---@param simple? boolean Never treat `if_t` and `if_f` as arg lists
---@return unknown
M.tern = function(cond, if_t, if_f, simple)
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

--- ***
---## ternary
---Return a value based on two values
---Equivalent to a ternary.
---@generic T, V
---@param cond any Statement to be tested
---@param if_t T Return if condition is truthy
---@param if_f V Return if condition is not truthy
---@return T | V
M.if_expr = function(cond, if_t, if_f)
    return M.tern(cond, if_t, if_f, true)
end

--- ***
---## if else nil
---Equivalent to a ternary that checks if the value is `nil`.
---```lua
---  if cond == nil then want else default end
---  M.if_expr(cond == nil, want, def)
---```
---@generic T, V
---@param cond any Value to check if `nil`
---@param if_n T Value to return if `cond` is `nil`
---@param if_not_n V Value to return if `cond` is not `nil`
---@return T | V
M.ife_nil = function(cond, if_n, if_not_n)
    return M.if_expr(cond == nil, if_n, if_not_n)
end

--- ***
---## if else not nil
---Equivalent to a ternary that checks if the value is not `nil`.
---```lua
---  if cond ~= nil then want else default end
---  M.if_expr(cond ~= nil, want, def)
---```
---@generic T, V
---@param cond any Value to check if `not nil`
---@param if_not_n T Value to return if `cond` is `not nil`
---@param if_not_not_n V Value to return if `cond` is not `not nil`
---@return T | V
M.ife_nnil = function(cond, if_not_n, if_not_not_n)
    return M.if_expr(cond ~= nil, if_not_n, if_not_not_n)
end

--- ***
---## if else true
---Equivalent to a ternary that checks if the value is true.
---```lua
---  if cond == true then want else default end
---  M.if_expr(cond == true, want, def)
---```
---@generic T, V
---@param cond any Value to check if `true`
---@param if_t T Value to return if `cond` is `true`
---@param if_not_t V Value to return if `cond` is not `true`
---@return T | V
M.ife_true = function(cond, if_t, if_not_t)
    return M.if_expr(cond == true, if_t, if_not_t)
end

--- ***
---## if else false
---Equivalent to a ternary that checks if the value is false.
---```lua
---  if cond == false then want else default end
---  M.if_expr(cond == false, want, def)
---```
---@generic T, V
---@param cond any Value to check if `false`
---@param if_f T Value to return if `cond` is `false`
---@param if_not_f V Value to return if `cond` is not `false`
---@return T | V
M.ife_false = function(cond, if_f, if_not_f)
    return M.if_expr(cond == false, if_f, if_not_f)
end

--- ***
---## if then
---Return another value if `val` is truthy
---```lua
---  if this then want else this end
---  M.if_expr(val, other, val)
---```
---@generic T, V
---@param val T value to check if truthy
---@param thenv V default value to return if `val` is truthy
---@return T|V
M.if_then = function(val, thenv)
    return M.if_expr(val, thenv, val)
end

--- ***
---## if then
---Return another value if `val` is false
---```lua
---  if not this then want else this end
---  M.if_expr(not val, other, val)
---```
---@generic T, V
---@param val T value to check if not truthy
---@param thenv V default value to return if `val` is not truthy
---@return T|V
M.ifn_then = function(val, thenv)
    return M.if_expr(not val, thenv, val)
end

--- ***
---## if true then
---Return another value if `val` is `true`
---Differs from `M.if_then` by checking for explicit `true`, not truthiness
---```lua
---  if this == true then other else this end
---  M.if_expr(val == true, other, val)
---  M.true_and()                       -- alt name for this func
---```
---@generic T, V
---@param val T value to check if `true`
---@param other V other value to return if `val` is `true`
---@return T | V
M.ift_then = function(val, other)
    return M.ife_true(val, other, val)
end

--- ***
---## if false then
---Return another value if `val` is `false`
---Differs from `M.ifn_then` by checking for explicit `false`, not non-truthiness
---```lua
---  if this == false then other else this end
---  M.if_expr(val == true, other, val)
---  M.false_and()                      -- alt name for this func
---```
---@generic T, V
---@param val T value to check if `false`
---@param other V other value to return if `val` is `false`
---@return T | V
M.iff_then = function(val, other)
    return M.ife_false(val, other, val)
end

--- ***
---## this if not nil or
---Return another value if `val` is nil
---```lua
---  if this == nil then other else this end
---  M.if_expr(val == nil, other, val)
---```
---@generic T, V
---@param val T value to check if `nil`
---@param default V default value to return if `val` is `nil`
---@return T | V
M.unwrap_or = function(val, default)
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

--- ***
---## this if true or
---Return `val` if `val` is `true`, else another
---```lua
---  if this == true then this else other end
---  M.if_expr(val == true, val, other)
---```
---@generic T, V
---@param val T value to check if `true`
---@param other V other value to return if `val` isn't `true`
---@return T | V
M.true_or = function(val, other)
    return M.ife_true(val, val, other)
end

--- ***
---## this if false or
---Return `val` if `val` is `false`, else another
---```lua
---  if this == false then this else other end
---  M.if_expr(val == false, val, other)
---```
---@generic T, V
---@param val T value to check if `false`
---@param other V other value to return if `val` isn't `false`
---@return T | V
M.false_or = function(val, other)
    return M.ife_false(val, val, other)
end

--- ***
---## if nil
---Returns the first argument which is not nil.
---If all arguments are nil, returns nil.
---@generic T : any
---@param ... T arguments to check if nil
---@return T
M.if_nil = function(...)
    local nargs = select("#", ...)
    for i = 1, nargs do
        local v = select(i, ...)
        if v ~= nil then
            return v
        end
    end
    return nil
end

--- ***
---## if true
---Returns true if any arguments are true, else false
---@param ... any arguments to check if true
---@return boolean
M.if_true = function(...)
    return C.any({...}, function(v)
        return v == true
    end)
end

--- ***
---## if true
---Returns true if any arguments are false, else false
---@param ... any arguments to check if false
---@return boolean
M.if_false = function(...)
    return C.any({...}, function(v)
        return v == false
    end)
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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

--- ***
---Bind a function to some arguments and return a new function that can be called later
---Useful for setting up callbacks without anonymous functions
---@generic A1, T: ...
---@generic R, F: fun(a1: A1, ...: T):R
---@param func F Function to be called
---@param ... T Arguments that are passed to `fn`
---@return F:fun(...:T):R fn Function that will accept more arguments
M.thunk = function(func, ...)
    local bound = {...}
    return function(...)
        return func(unpack(vim.list_extend(vim.list_extend({}, bound), {...})))
    end
end

function M.partial2(fun, ...)
    local args = {...}
    return function(...)
        return fun(unpack(args), ...)
    end
end

--
-- M.partial = function(func, ...)
--     local args = {...}
--     return function(self, ...)
--         return func(self, unpack(_.concat(args, {...})))
--     end
-- end
--
-- M.bind2 = function(fn, ...)
--     if select("#", ...) == 1 then
--         local arg = ...
--         return function(...)
--             fn(arg, ...)
--         end
--     end
--
--     local args = tbl.pack(...)
--     return function(...)
--         fn(tbl.unpack(args), ...)
--     end
-- end
--
-- M.bind = function(func, context, ...)
--     local arguments = {...}
--     return function(...)
--         return func(context, unpack(_.concat(arguments, {...})))
--     end
-- end

--- ***
---Like `thunk()`, but arguments passed to the thunk are ignored
---@generic T: ..., R
---@param func? fun(...: T): R Function to be called
---@param ... T Arguments that are passed to `fn`
---@return fun(): R fn Function that will not accept more arguments
M.ithunk = function(func, ...)
    local bound = {...}
    return function()
        return func and func(unpack(bound))
    end
end

--- ***
---Same as `ithunk()`, except prefixed with a `pcall`
---@generic T: ..., R
---@param func fun(...: T): R Function to be called
---@param ... T Arguments that are passed to `fn`
---@return fun(): R fn Function that will not accept more arguments
M.pithunk = function(func, ...)
    return M.ithunk(pcall, func, ...)
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
M.memoize = function(func)
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

M.memo = setmetatable({
    put = function(cache, params, result)
        local node = cache
        for i = 1, #params do
            local param = vim.inspect(params[i])
            node.children = node.children or {}
            node.children[param] = node.children[param] or {}
            node = node.children[param]
        end
        node.result = result
    end,
    get = function(cache, params)
        local node = cache
        for i = 1, #params do
            local param = vim.inspect(params[i])
            node = node.children and node.children[param]
            if not node then
                return nil
            end
        end
        return node.result
    end,
}, {
    __call = function(self, func)
        local cache = {}

        return function(...)
            local params = {...}
            local result = self.get(cache, params)
            if not result then
                result = {func(...)}
                self.put(cache, params, result)
            end
            return unpack(result)
        end
    end,
})

--- ***
---Run a function one time during the vim session
---@generic T: ..., R
---@param func fun(a: T): R function to call once
---@return fun(a: T): R
M.onceg = function(func)
    return M.memoize(func)
end

--- ***
---Call a function one time.
---Returns a table with function `reset`, which will reset the 'once' call
---@generic T : ..., R
---@param func fun(a?: T): R? function to call once
---@return {__call: fun(a?: T): R?, reset: fun()}
M.once = function(func)
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

---Use in combination with pcall
---@generic T
---@param status boolean status from `pcall`
---@param ... `T`
---@return T?
M.ok_or_nil = function(status, ...)
    if not status then
        local args = _t({...})
        local msg = args:concat("\n"):split("\n")
        local mod = msg[1]:match("module '(%w.*)'")
        C.vec_insert(
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

--- ***
---Nil `pcall`.
---If `pcall` succeeds, return result of `fn`, else `nil`
---## Example:
---```lua
---  require('usr.shared').F.npcall(require, 'ufo')
---```
---@generic V, R
---@generic T : fun()
---@param func T<fun(v: V): `R`?> function to call
---@param ... V arguments to function
---@return R?
M.npcall = function(func, ...)
    return M.ok_or_nil(pcall(func, ...))
end

--- ***
---Wrap a function to return `nil` if it fails, otherwise the value
---## Example:
---```lua
---  require('usr.shared').F.nil_wrap(require)('ufo')
---```
---@generic T : fun()
---@param func T function to wrap with a call
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

    local f = __FILE__()
    local tb = __TRACEBACK__()

    return xpcall(
        func,
        function(err)
            local errsp = err:split("\n")
            local title = M.unwrap_or(msg, errsp[1])
            local body = M.if_expr(msg == nil, _t(errsp):slice(2), _t(errsp))
            C.vec_insert(body, "", ("File     : %s"):format(f), ("Traceback: %s"):format(tb), "")

            vim.schedule(
                function()
                    log.err(body, {title = title, once = true})
                end
            )
        end,
        unpack(args)
    )
end

return M
