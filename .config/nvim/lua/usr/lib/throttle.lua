---@module 'usr.lib.throttle'
---@generic T
---@class Throttle<T>
---@field timer uv_timer_t|nil
---@field fn fun(...: any) fun(...: T)
---@field pending_args? any[] T[]
---@field limit number
---@field leading? boolean
---@field trailing? boolean
---@overload fun(fn: fun(...: any), limit: number, no_leading?: boolean, no_trailing?: boolean): Throttle
local Throttle = {}

local uv = vim.uv

---Create a new `Throttle` instance
---@generic T
---@param fn fun(...: T[])
---@param limit number
---@param no_leading? boolean
---@param no_trailing? boolean
---@return Throttle<T>
function Throttle:new(fn, limit, no_leading, no_trailing)
    vim.validate({fn = {fn, 'function'}, limit = {limit, 'number'},
                  no_leading = {no_leading, 'boolean', true},
                  no_trailing = {no_trailing, 'boolean', true}})
    assert(not (no_leading and no_trailing),
           [[values of no_leading and no_trailing can't both be true]])
    local o = setmetatable({}, self)
    o.timer = nil
    o.fn = vim.schedule_wrap(fn)
    o.pending_args = nil
    o.limit = limit
    o.leading = not no_leading
    o.trailing = not no_trailing
    return o
end

---Execute the function
---@param ... any
function Throttle:call(...)
    local timer = self.timer
    if not timer then
        ---@type uv_timer_t
        timer = uv.new_timer()
        self.timer = timer
        local limit = self.limit
        timer:start(limit, 0, function()
            if self.pending_args then
                self.fn(unpack(self.pending_args))
            end
            self:cancel()
        end)
        if self.leading then
            self.fn(...)
        else
            self.pending_args = {...}
        end
    else
        if self.trailing then
            self.pending_args = {...}
        end
    end
end

---Reset the timer
function Throttle:cancel()
    local timer = self.timer
    if timer then
        -- if timer:has_ref() and not timer:is_closing() then
        --     timer:close()
        -- end
        if timer:has_ref() then
            timer:stop()
            if not timer:is_closing() then
                timer:close()
            end
        end
    end
    self.timer = nil
    self.pending_args = nil
end

Throttle.__index = Throttle
Throttle.__call = Throttle.call

return setmetatable(Throttle, {
    __call = Throttle.new
})
