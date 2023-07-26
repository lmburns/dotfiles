---@module 'usr.lib.debounce'
---@generic T
---@class Debounce<T>
---@field timer uv_timer_t|nil
---@field fn fun(...: any) fun(...: T)
---@field args any[] T[]
---@field wait number
---@field leading? boolean
---@operator call:nil
---@overload fun(fn: fun(...: any), wait: number, leading?: boolean): Debounce
local Debounce = {}

local F = Rc.F
local uv = vim.uv

---Create a new `Debounce` instance
---@generic T : any
---@param fn fun(...: T)
---@param wait number
---@param leading? boolean
---@return Debounce<T>
function Debounce:new(fn, wait, leading)
    vim.validate({
        fn = {fn, "f"},
        wait = {wait, "n"},
        leading = {leading, "b", true},
    })
    local o = setmetatable({}, self)
    o.timer = nil
    o.fn = vim.schedule_wrap(fn)
    o.args = nil
    o.wait = wait
    o.leading = leading
    return o
end

---Execute the function
---@param ... any
function Debounce:call(...)
    local timer = self.timer
    self.args = {...}
    if not timer then
        ---@type uv_timer_t
        timer = uv.new_timer()
        self.timer = timer
        local wait = self.wait
        timer:start(wait, wait, F.tern(
            self.leading,
            function() self:cancel() end,
            function() self:flush() end
        ))
        if self.leading then
            self.fn(...)
        end
    else
        timer:again()
    end
end

---Reset the timer
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

---Returns a function that has a reference to the original instance.
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
