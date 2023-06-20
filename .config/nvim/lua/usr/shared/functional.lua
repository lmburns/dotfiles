---@module 'usr.shared.functional'
---@class Usr.Shared.F
local M = {}

local lazy = require("usr.lazy")
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'
local C = lazy.require("usr.shared.collection") ---@module 'usr.shared.collection'

M.op = lazy.require("usr.shared.op") ---@module 'usr.shared.op'

---## ternary
--- ***
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
--- ***
---@generic T, V
---@param cond? any|boolean|fun():boolean Statement to be tested
---@param if_t T Return if cond is truthy
---@param if_f V Return if cond is not truthy
---@param simple? boolean Never treat `if_t` and `if_f` as arg lists
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
--- ***
---Return a value based on two values
---Equivalent to a ternary.
---@generic T, V
---@param cond any Statement to be tested
---@param if_t T Return if condition is truthy
---@param if_f V Return if condition is not truthy
---@return T | V
function M.if_expr(cond, if_t, if_f)
    return M.tern(cond, if_t, if_f, true)
end

---## if else nil
--- ***
---Equivalent to a ternary that checks if the value is `nil`.
---```lua
---  if cond == nil then want else default end
---  M.if_expr(cond == nil, want, def) == M.ife_nil(cond, want, def)
---```
--- ***
---@generic T, V
---@param cond any Value to check if `nil`
---@param if_n T Value to return if `cond` is `nil`
---@param if_not_n V Value to return if `cond` is not `nil`
---@return T | V
function M.ife_nil(cond, if_n, if_not_n)
    return M.if_expr(cond == nil, if_n, if_not_n)
end

---## if else not nil
--- ***
---Equivalent to a ternary that checks if the value is not `nil`.
---```lua
---  if cond ~= nil then want else default end
---  M.if_expr(cond ~= nil, want, def)
---```
--- ***
---@generic T, V
---@param cond any Value to check if `not nil`
---@param if_not_n T Value to return if `cond` is `not nil`
---@param if_not_not_n V Value to return if `cond` is not `not nil`
---@return T | V
function M.ife_nnil(cond, if_not_n, if_not_not_n)
    return M.if_expr(cond ~= nil, if_not_n, if_not_not_n)
end

---## if else true
--- ***
---Equivalent to a ternary that checks if the value is true.
---```lua
---  if cond == true then want else default end
---  M.if_expr(cond == true, want, def)
---```
--- ***
---@generic T, V
---@param cond any Value to check if `true`
---@param if_t T Value to return if `cond` is `true`
---@param if_not_t V Value to return if `cond` is not `true`
---@return T | V
function M.ife_true(cond, if_t, if_not_t)
    return M.if_expr(cond == true, if_t, if_not_t)
end

---## if else false
--- ***
---Equivalent to a ternary that checks if the value is false.
---```lua
---  if cond == false then want else default end
---  M.if_expr(cond == false, want, def)
---```
--- ***
---@generic T, V
---@param cond any Value to check if `false`
---@param if_f T Value to return if `cond` is `false`
---@param if_not_f V Value to return if `cond` is not `false`
---@return T | V
function M.ife_false(cond, if_f, if_not_f)
    return M.if_expr(cond == false, if_f, if_not_f)
end

---## if then
--- ***
---Return another value if `val` is truthy
---```lua
---  if this then want else this end
---  M.if_expr(val, other, val)
---```
--- ***
---@generic T, V
---@param val T value to check if truthy
---@param thenv V default value to return if `val` is truthy
---@return T|V
function M.if_then(val, thenv)
    return M.if_expr(val, thenv, val)
end

---## if then
--- ***
---Return another value if `val` is false
---```lua
---  if not this then want else this end
---  M.if_expr(not val, other, val)
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
--- ***
---Return another value if `val` is `true`
---Differs from `M.if_then` by checking for explicit `true`, not truthiness
---```lua
---  if this == true then other else this end
---  M.if_expr(val == true, other, val)
---  M.true_and()                       -- alt name for this func
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
--- ***
---Return another value if `val` is `false`
---Differs from `M.ifn_then` by checking for explicit `false`, not non-truthiness
---```lua
---  if this == false then other else this end
---  M.if_expr(val == true, other, val)
---  M.false_and()                      -- alt name for this func
---```
--- ***
---@generic T, V
---@param val T value to check if `false`
---@param other V other value to return if `val` is `false`
---@return T | V
function M.iff_then(val, other)
    return M.ife_false(val, other, val)
end

---## this if not nil or
--- ***
---Return another value if `val` is nil
---```lua
---  if this == nil then other else this end
---  M.if_expr(val == nil, other, val)
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

---## this if true or
--- ***
---Return `val` if `val` is `true`, else another
---```lua
---  if this == true then this else other end
---  M.if_expr(val == true, val, other)
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
--- ***
---Return `val` if `val` is `false`, else another
---```lua
---  if this == false then this else other end
---  M.if_expr(val == false, val, other)
---```
--- ***
---@generic T, V
---@param val T value to check if `false`
---@param other V other value to return if `val` isn't `false`
---@return T | V
function M.false_or(val, other)
    return M.ife_false(val, val, other)
end

---## if nil
--- ***
---Returns the first argument which is not nil.
---If all arguments are nil, returns nil.
---@generic T : any
---@param ... T arguments to check if nil
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
--- ***
---Returns true if any arguments are true, else false
---@param ... any arguments to check if true
---@return boolean
function M.if_true(...)
    return C.any({...}, function(v)
        return v == true
    end)
end

---## if true
--- ***
---Returns true if any arguments are false, else false
---@param ... any arguments to check if false
---@return boolean
function M.if_false(...)
    return C.any({...}, function(v)
        return v == false
    end)
end

--  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---Identity function
---@generic R
---@param ... R
---@return R ... #the arguments passed to the function
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
---@return T
function M.const(value)
    return function()
        return value
    end
end

---@class ThunkFn<T1, T2, R> : function(init: T1, ...: T2): R

---Bind a function to some arguments and return a new function that can be called later
---Useful for setting up callbacks without anonymous functions
---```lua
---  thunk(fn, A1)(A2) == fn(A1, A2)
---  thunk(p, "1", "2")("3")  --> "1 2 3"
---```
--- ***
---@generic T1, T2, R
---@param func ThunkFn<T1, T2, R> function to be called
---@param ... T1 arguments that are passed to `func`
---@return fun(...: T2): R fn function that will accept more arguments
function M.thunk(func, ...)
    local bound = {...}
    return function(...)
        return func(unpack(vim.list_extend(vim.list_extend({}, bound), {...})))
    end
end

---@class IThunkFn<T, R> : function(...: T): R

---Like `thunk()`, but arguments passed to the thunk are ignored
---Overview: calling return is equivalent to `func(...: A1)`
---```lua
---  ithunk(fn, A1)(A2) == fn(A1)
---  ithunk(p, "1", "2")("3")  --> "1 2"
---```
--- ***
---@generic T, R
---@param func IThunkFn<T, R> function to be called
---@param ... T arguments that are passed to `func`
---@return fun(): R fn function that will not accept more arguments
function M.ithunk(func, ...)
    local bound = {...}
    return function()
        return func and func(unpack(bound))
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

-- FIX: there must be a naming error with bind and the langserver

---@class BindFn<C, T1, T2, R> : function(ctx: C, init: T1, ...: T2): R

---Bind a function to a table, allowing for self to be used, referencing the table.
---Optionally, bind arguments to the function to pre-fill them, also known as partial application.
---Overview: `bind(fn, ctx, A1)(A2)` == `fn(ctx, A1, A2)`
--- ***
---```lua
---  local disp = function(self, echo) return ("%s: %s"):format(echo, self.arg) end
---  local bound = F.bind(disp, {arg = "this will echo"})
---  bound("greetings")  --> 'greetings: this will echo'
---
---  bound = F.bind(disp, {arg = "this will echo"}, "second")
---  bound()  --> 'second: this will echo'
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
        return func(context, unpack(vim.list_extend({...}, bound)))
    end
end

---@class IBindFn<C, T, R> : function(ctx: C, ...: T): R

---Like `bind()`, except all later arguments are ignored.
---Overview: calling return is equivalent to `func(context, ...: A1)`
---Overview: `ibind(fn, ctx, A1)(A2)` == `fn(ctx, A1)`
--- ***
---@generic C, T, R
---@param func IBindFn<C, T, R> function to be called
---@param context C context passed to `func`
---@param ... T arguments that are passed to `func`
---@return fun(): R fn function that will not accept more arguments
function M.ibind(func, context, ...)
    local bound = {...}
    return function()
        return func(context, unpack(bound))
    end
end

---@class PartialFn<T1, T2, R> : function(self, init: T1, ...: T2): R

---Partially bind a function to arguments.
---Unlike bind, the optional arguments are what is referred to as `self`.
---Overview: `partial(fn, A1)(A2)` == `fn(self, A1, A2)`
--- ***
---```lua
---  local obj = {id = "tbl"}
---  local f = function(self, a1, a2, a3) return ("%s: %s):format(self.id, _j({a1, a2, a3}):concat('-')) end
---  obj.f = F.partial(f, 'abc', 'def')
---  assert(obj:f('ghi') == 'tbl: abc-def-ghi')
---
---  local disp = function(self, echo) return ("%s: %s"):format(echo, self.arg) end
---  local bound = F.partial(disp, 'greetings')
---  bound({arg = "this will echo"})  --> 'greetings: this will echo'
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

---@class IPartialFn<T, R> : function(self, ...: T): R

---Like `partial`, except all later arguments
---(minus the first, i.e., what is passed becomes `self`) are ignored.
---Overview: `ipartial(fn, A1)({i = 1}, A2)` == `fn(self as {i = 1}, A1)`
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

---@class WrapFn1<T, R> : function(...: T): R
---@class WrapFn2<T, R1, R2> : function(WrapF1<T, R1>): R2

--- ***
---Return the first func passed as an argument to the second
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

function M.apply(func, ...)
    local params = C.pack(...)
    local count = params.n
    local offest = count - 1
    local packed = params[count]

    if type(packed) == "table" then
        params[count] = nil
        for index, item in pairs(packed) do
            if (type(index) == "number") then
                count = offest + index
                params[count] = item
            end
        end
    end

    return func(unpack(params, 1, count))
end

---Return a negated function of the passed-in function
---@generic R
---@param func fun(...): R
---@return fun(...): R
function M.compliment(func)
    return function(...)
        return not func(...)
    end
end

M.negate = M.compliment

---Return a function consisting of a list of functions,
---each consumes the return value of the function that follows.
---It is equivalent to the composing funcs of `f`, `g`, and `h` producing the function `f(g(h(...)))`.
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
--     --  return setTimeout(function(){
--     --    return func.apply(null, args);
--     --  }, wait);
-- end

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

---@class FlipFn<T, R> : function(...: T): R

---Return a function with with arguments reversed.
---@generic T, R
---@param func FlipFn<T, R>
---@return fun(...: T): R
function M.flip(func)
    return function(...)
        return func(unpack(_j({...}):reverse()))
    end
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

--- ***
---Run a function one time during the vim session
---@generic T: ..., R
---@param func fun(a: T): R function to call once
---@return fun(a: T): R
function M.onceg(func)
    return M.memoize(func)
end

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

--- ***
---Nil `pcall`.
---If `pcall` succeeds, return result of `func`, else `nil`
---## Example:
---```lua
---  require('usr.shared').F.npcall(require, 'ufo')
---```
---@generic V, R
---@generic T : fun()
---@param func T<fun(v: V): `R`?> function to call
---@param ... V arguments to function
---@return R?
function M.npcall(func, ...)
    return M.ok_or_niln(pcall(func, ...))
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
---@param ... `T`
---@return T ...
function M.ok_or_niln(status, ...)
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

            vim.schedule(function()
                log.err(body, {title = title, once = true})
            end)
        end,
        unpack(args)
    )
end

return M
