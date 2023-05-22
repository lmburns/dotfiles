---@module 'usr.shared.functional'
local M = {}

local lazy = require("usr.lazy")
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'
local collection = lazy.require("usr.shared.collection") ---@module 'usr.shared.collection'
local vec = collection.vec

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
---@param cond? any|boolean|fun():boolean Statement to be tested
---@param is_if T Return if cond is truthy
---@param is_else V Return if cond is not truthy
---@param simple? boolean Never treat `is_if` and `is_else` as arg lists
---@return unknown
M.tern = function(cond, is_if, is_else, simple)
    if cond then
        if not simple and type(is_if) == "table" and vim.is_callable(is_if[1]) then
            return is_if[1](vec.select(is_if, 2))
        end
        return is_if
    else
        if not simple and type(is_else) == "table" and vim.is_callable(is_else[1]) then
            return is_else[1](vec.select(is_else, 2))
        end
        return is_else
    end
end

---Return a value based on two values
---@generic T, V
---@param cond any Statement to be tested
---@param is_if T Return if condition is truthy
---@param is_else V Return if condition is not truthy
---@return T | V
M.if_expr = function(cond, is_if, is_else)
    return M.tern(cond, is_if, is_else, true)
end

---@param ... any
---@return any
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

---## if else nil
---Similar to `vim.F.nil` except that:
---   - a default value can be given
---   - `if cond == nil then want else default`
---   - `M.if_expr(cond == nil, want, def)`
---@generic T, V
---@param cond any Value to check if `nil`
---@param is_nil T Value to return if `cond` is `nil`
---@param is_not_nil V Value to return if `cond` is not `nil`
---@return T | V
M.ife_nil = function(cond, is_nil, is_not_nil)
    return M.if_expr(cond == nil, is_nil, is_not_nil)
end

---## if else not nil
---Similar to `vim.F.nil` except that:
---   - a default value can be given
---   - value is checked to be not nil
---   - `if cond ~= nil then want else default`
---   - `M.if_expr(cond ~= nil, want, def)`
---@generic T, V
---@param cond any Value to check if `not nil`
---@param is_not_nil T Value to return if `cond` is `not nil`
---@param is_not_not_nil V Value to return if `cond` is not `not nil`
---@return T | V
M.ife_nnil = function(cond, is_not_nil, is_not_not_nil)
    return M.if_expr(cond ~= nil, is_not_nil, is_not_not_nil)
end

---## if else true
---Similar to `vim.F.nil` except that:
---   - a default value can be given
---   - value is checked to be true
---   - `if cond == true then want else default`
---   - `M.if_expr(cond == true, want, def)`
---@generic T, V
---@param cond any Value to check if `true`
---@param is_true T Value to return if `cond` is `true`
---@param is_not_true V Value to return if `cond` is not `true`
---@return T | V
M.ife_true = function(cond, is_true, is_not_true)
    return M.if_expr(cond == true, is_true, is_not_true)
end

---## if else false
---Similar to `vim.F.nil` except that:
---   - a default value can be given
---   - value is checked to be false
---   - `if cond == false then want else default`
---   - `M.if_expr(cond == false, want, def)`
---@generic T, V
---@param cond any Value to check if `false`
---@param is_false T Value to return if `cond` is `false`
---@param is_not_false V Value to return if `cond` is not `false`
---@return T | V
M.ife_false = function(cond, is_false, is_not_false)
    return M.if_expr(cond == false, is_false, is_not_false)
end

---## if then
---Return a default value if `val` is truthy
---   - `if val then want else val`
---   - `M.if_expr(val, def, val)`
---@generic T, V
---@param val T value to check
---@param thenv V default value to return if `val` is truthy
---@return T|V
M.if_then = function(val, thenv)
    return M.if_expr(val, thenv, val)
end

---## if nil then
---Return a default value if `val` is nil
---   - `if val == nil then default else val`
---   - `M.if_expr(val == nil, def, val)`
---   - `ifn_then`
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

---## if not nil then
---Return a default value if `val` is `not nil`
---   - `if val ~= nil then want else val`
---   - `M.if_expr(val ~= nil, def, val)`
---   - `ifnn_then`
---@generic T, V
---@param val T value to check if not `nil`
---@param is_nnil V default value to return if `val` is `not nil`
---@return T | V
M.nnil_or = function(val, is_nnil)
    return M.ife_nnil(val, is_nnil, val)
end

---## if true then
---Return a default value if `val` is `true`
---   - `if val == true then want else val`
---   - `M.if_expr(val == true, def, val)`
---   - `ift_then`
---@generic T, V
---@param val T value to check if `true`
---@param is_true V default value to return if `val` is `true`
---@return T | V
M.true_or = function(val, is_true)
    return M.ife_true(val, is_true, val)
end

---## if false then
---Return a default value if `val` is `false`
---   - `if val == false then want else val`
---   - `M.if_expr(val == false, def, val)`
---   - `iff_then`
---@generic T, V
---@param val T value to check if `false`
---@param is_false V default value to return if `val` is `false`
---@return T | V
M.false_or = function(val, is_false)
    return M.ife_false(val, is_false, val)
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
M.if_true = if_fn(true)

---Returns the first argument which is false.
---If no arguments are false, nil is returned.
M.if_false = if_fn(false)

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

-- M.bind = M.thunk
-- M.ibind = M.ithunk
-- M.pibind = M.pithunk

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
---@generic T: ..., R
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

---Run a function one time during the vim session
---@generic T: ..., R
---@param func fun(a: T): R
---@return fun(a: T): R
M.onceg = function(func)
    return M.memoize(func)
end

---Call a function one time.
---Returns a table with function `reset`, which will reset the 'once' call
---@generic T: ..., R
---@param func fun(a?: T): R?
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
---@param status boolean
---@param ... `T`
---@return T?
M.ok_or_nil = function(status, ...)
    if not status then
        local args = _t({...})
        local msg = args:concat("\n"):split("\n")
        local mod = msg[1]:match("module '(%w.*)'")
        vec.insert(
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
---  require('usr.shared').F.npcall(require, 'ufo')
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
---  require('usr.shared').F.nil_wrap(require)('ufo')
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
            vec.insert(body, "", ("File     : %s"):format(f), ("Traceback: %s"):format(tb), "")

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
