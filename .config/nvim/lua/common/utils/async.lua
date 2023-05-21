---@module 'common.utils.async'
---@description Async utility functions
local M = {}

local lazy = require("common.lazy")
-- local debounce = require("common.debounce")
-- local disposable = require("common.disposable")
-- local uva = require("uva")
-- local async = require("async")
local promise = require("promise")
local utils = lazy.require_on.expcall("common.utils")

local uv = vim.loop
local F = vim.F

-- M.setTimeout = require("promise").loop.setTimeout

---Set a timeout and execute callback
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

---Set a timeout and execute callback while yielding to vim
---@param callback fun()
---@param ms integer
---@return uv_timer_t?
function M.setTimeoutv(callback, ms)
    local timer = uv.new_timer()
    if timer then
        timer:start(
            ms,
            0,
            vim.schedule_wrap(function()
                if not timer:is_closing() then
                    timer:close()
                end
                callback()
            end)
        )
    end
    return timer
end

---@class Closeable
---@field close fun() # Perform cleanup and release the associated handle.

---@class ManagedFn : Closeable

---Repeatedly call a function with a fixed time delay
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
---@param interval integer delay between executions (ms)
---@param max_interval? integer max times to run interval (300)
---@return Closeable
function M.setInterval(callback, interval, max_interval)
    local timer = uv.new_timer()
    local cnt = 0
    local ret = {
        close = function()
            ---@diagnostic disable:need-check-nil
            if timer:has_ref() then
                timer:stop()
                if not timer:is_closing() then
                    timer:close()
                end
            end
        end,
    }
    if timer then
        timer:start(
            interval,
            interval,
            function()
                local should_close = callback(timer, cnt)
                cnt = cnt + 1
                if
                    (utils.is.bool(should_close) and should_close) or
                    cnt == F.unwrap_or(max_interval, 300)
                then
                    ret.close()
                end
            end
        )
    end
    return ret
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

---Return an already timed out promise that yields to vim
---@param ms integer
---@return Promise
function M.waitv(ms)
    return promise(
        function(resolve)
            return M.setTimeoutv(resolve, ms)
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

local scheduler = M.wrap(vim.schedule, 1)

---Used like:
---```lua
---  async.scheduler():thenCall(function() ... end)
---```
---@return Promise
function M.scheduler()
    return scheduler()
end

local function wrap_vim(prop)
    return setmetatable(
        {},
        {
            __index = function(_, k)
                return function(...)
                    local argv = {...}
                    return async(function()
                        if vim.in_fast_event() then
                            await(M.scheduler())
                        end

                        return vim[prop][k](unpack(argv))
                    end)
                end
            end,
        }
    )
end

M.fn = wrap_vim("fn") ---@type vim.fn
M.api = wrap_vim("api") ---@type vim.api

--  ══════════════════════════════════════════════════════════════════════

local M2 = require("common.utils")
M2.async = M

return M
