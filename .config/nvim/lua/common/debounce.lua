local uv = vim.loop
local F = vim.F

---@generic T
---@class Debounce<T>
---@field timer userdata|nil
---@field fn fun(...: any) fun(...: T)
---@field args any[] T[]
---@field wait number
---@field leading? boolean
---@operator call():nil
---@overload fun(fn: fun(...: any), wait: number, leading?: boolean): Debounce
local Debounce = {}

---Create a new `Debounce` instance
---@generic T
---@param fn fun(...: T[])
---@param wait number
---@param leading? boolean
---@return Debounce<T>
function Debounce:new(fn, wait, leading)
    vim.validate({
        fn = {fn, "function"},
        wait = {wait, "number"},
        leading = {leading, "boolean", true},
    })
    local obj = setmetatable({}, self)
    obj.timer = nil
    obj.fn = vim.schedule_wrap(fn)
    obj.args = nil
    obj.wait = wait
    obj.leading = leading
    return obj
end

---Execute the function
---@param ... any
function Debounce:call(...)
    local timer = self.timer
    self.args = {...}
    if not timer then
        ---@type userdata
        timer = uv.new_timer()
        self.timer = timer
        local wait = self.wait
        timer:start(
            wait,
            wait,
            F.if_expr(
                self.leading,
                function()
                    self:cancel()
                end,
                function()
                    self:flush()
                end
            )
        )
        if self.leading then
            self.fn(...)
        end
    else
        timer:again()
    end
end

---Reset the debounce timer
function Debounce:cancel()
    local timer = self.timer
    if timer then
        if timer:has_ref() then
            timer:stop()
            if not timer:is_closing() then
                timer:close()
            end
        end
        self.timer = nil
    end
end

---Reset the timer if there is one and execute the function
function Debounce:flush()
    if self.timer then
        self:cancel()
        self.fn(unpack(self.args))
    end
end

---Returns a normal function which, when called,
---calls `Debounce:call()` bound to the original instance.
---
---Useful for using Debounce with an API that doesn't accept callable tables.
---@return fun(...)
function Debounce:ref()
    return function(...)
        self:call(...)
    end
end

Debounce.__index = Debounce
Debounce.__call = Debounce.call

---Calling this module will create a new `Debounce` instance
---Calling the returned value of the aforementioned call will call `Debouce.call`
return setmetatable(Debounce, {
    __call = Debounce.new,
})
