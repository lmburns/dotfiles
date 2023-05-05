---@description: Async utility functions
---@module "common.utils.async"
local M = {}

-- local debounce = require("common.debounce")
-- local disposable = require("common.disposable")
-- local uva = require("uva")
-- local async = require("async")
local promise = require("promise")

local uv = vim.loop
local F = vim.F

-- M.setTimeout = require("promise").loop.setTimeout

---Set a timeout
---@param callback fun()
---@param ms integer
---@return uv_timer_t?
function M.setTimeout(callback, ms)
    local timer = uv.new_timer()
    if timer then
        timer:start(
            ms,
            0,
            function()
                timer:close()
                callback()
            end
        )
    end
    return timer
end

---Set an interval to exec function
---```lua
---  M.setInterval(function(t, c)
---      if c == 3 then
---          t:close() -- Make sure to close the handle
---          p("done")
---      else
---          p(("tick: %s"):format(c))
---      end
---  end, 1000)
---  -- tick 1
---  -- tick 2
---  -- done
---```
---@param callback fun(t: uv_timer_t, cnt: integer)
---@param interval integer
---@param max_interval? integer max times to run interval (300)
---@return uv_timer_t?
function M.setInterval(callback, interval, max_interval)
    local timer = uv.new_timer()
    local cnt = 0
    if timer then
        timer:start(
            interval,
            interval,
            function()
                callback(timer, cnt)
                cnt = cnt + 1
                if cnt == F.unwrap_or(max_interval, 300) then
                    timer:close()
                end
            end
        )
    end
    return timer
end

---Return an already timed out promise
---@param ms integer
---@return Promise
function M.wait(ms)
    return promise(
        function(resolve)
            return M.setTimeout(resolve, ms)
        end
    )
end

---This might not be possible to generalize
---Wrap a function that takes a callback as a last arg with a promise
---@generic T
---@param func fun(...: T) callback style func. last arg must be the callback
---@param argc integer number of function args
---@return fun(...: T): Promise
function M.wrap(func, argc)
    return function(...)
        local argv = {...}
        return promise(
            function(resolve, reject)
                argv[argc] = function(err, data)
                    if err then
                        reject(err)
                    else
                        resolve(data)
                    end
                end
                func(unpack(argv))
            end
        )
    end
end

---Used like:
---```lua
---  async.scheduler():thenCall(function() ... end)
---```
M.scheduler = M.wrap(vim.schedule, 1)

--  ╭──────────────────────────────────────────────────────────╮
--  │                        coroutine                         │
--  ╰──────────────────────────────────────────────────────────╯

M.co = {}

---Executes a future with a callback when it is done
---@param func fun() future to exec
---@param ... any
local function execute(func, ...)
    local thread = coroutine.create(func)

    local function step(...)
        local ret = {coroutine.resume(thread, ...)}
        local stat, err_or_fn, nargs = unpack(ret)

        if not stat then
            error(string.format("The coroutine failed with this message: %s\n%s",
                err_or_fn, debug.traceback(thread)))
        end

        if coroutine.status(thread) == "dead" then
            return
        end

        local args = {select(4, unpack(ret))}
        args[nargs] = step
        err_or_fn(unpack(args, 1, nargs))
    end

    step(...)
end

---@async
---Creates an async function with a callback style function.
---@generic T, A
---@param func fun(...: A): T A callback style function to be converted. The last argument must be the callback.
---@param argc number: The number of arguments of func. Must be included.
---@return fun(...: A): T Returns an async function
function M.co.wrap(func, argc)
    return function(...)
        if not coroutine.running() or select("#", ...) == argc then
            return func(...)
        end
        return coroutine.yield(func, argc, ...)
    end
end

---Use this to create a function which executes in an async context but
---called from a non-async context. Inherently this cannot return anything
---since it is non-blocking
---@generic T, A
---@param func fun(...: A): T
---@return fun(...: A): T
function M.co.void(func)
    return function(...)
        if coroutine.running() then
            return func(...)
        end
        execute(func, ...)
    end
end

---An async function that when called will yield to the Neovim scheduler to be
---able to call the API.
M.co.scheduler = M.co.wrap(vim.schedule, 1)

--  ══════════════════════════════════════════════════════════════════════

local M2 = require("common.utils")
M2.async = M

return M
