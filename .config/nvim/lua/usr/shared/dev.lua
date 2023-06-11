---@module 'usr.shared.dev'
---@class Usr.Shared.Dev
local M = {}

local lazy = require("usr.lazy")
local log = lazy.require("usr.lib.log") ---@module 'usr.lib.log'

---@generic T, R
---@param msg string|nil|fun(v: T): R
---@param func fun(v: T): R
---@param ... T
---@return R
function M.perf(msg, func, ...)
    local args = {...}
    if type(msg) == "function" then
        func, args, msg = msg, {func, unpack(args)}, nil
    end
    local start = uv.hrtime()
    local data = func(...)
    local fin = uv.hrtime() - start
    vim.schedule(function()
        vim.notify(("Elapsed time: %.5fs"):format(fin), log.levels.INFO, {title = msg})
    end)
    return data
end

---@param num number
---@param p? number
---@return number
function M.round(num, p)
    p = p or 1
    return math.floor(num / p + .5) * p
end

---@param num number
---@param p? number
---@return number
function M.floor(num, p)
    p = p or 1
    return math.floor(num / p) * p
end

---@param num number
---@param p? number
---@return number
function M.ceil(num, p)
    p = p or 1
    return math.ceil(num / p) * p
end

---Return 1 if positive, -1 if negative, or 0 if 0
---@param value number
---@return 1|0|-1
function M.sign(value)
    return value > 0 and 1 or value == 0 and 0 or -1
end

function M.nextpow2(x)
    return math.max(0, 2 ^ (math.ceil(math.log(x) / math.log(2))))
end

---If the value is less than min, return `min`
---If the value is greater than max, return `max`
---If the value is in-between min and max, return `value`
---@param value number
---@param min number
---@param max number
---@return number
function M.clamp(value, min, max)
    --     return math.min(math.max(value, min), max)
    if value < min then
        return min
    end
    if value > max then
        return max
    end
    return value
end

return M
