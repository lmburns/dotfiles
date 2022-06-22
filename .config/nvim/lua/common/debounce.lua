local uv = vim.loop
local Debounce = {}

---Execute the function to debounce.
--- This is called when the returned function from this module is called
---@vararg any
function Debounce:call(...)
    local args = {...}
    local timer = self.timer
    if not timer then
        timer = uv.new_timer()
        self.timer = timer
        local wait = self.wait
        timer:start(
            wait,
            wait,
            function()
                self:flush(unpack(args))
            end
        )
    else
        timer:again()
    end
end

function Debounce:clear()
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

function Debounce:flush(...)
    self:clear()
    self.fn(...)
end

---ref() returns a normal function which, when called, calls Debounce:call()
---bound to the original instance.
---Useful for using Debounce with an API that doesn't accept callable tables.
function Debounce:ref()
    return function(...)
        self:call(...)
    end
end

Debounce.__index = Debounce
Debounce.__call = Debounce.call

return setmetatable(
    {},
    {
        __call = function(_, fn, wait)
            vim.validate({fn = {fn, "function"}, wait = {wait, "number"}})
            local obj = {}
            setmetatable(obj, Debounce)
            obj.timer = nil
            obj.fn = vim.schedule_wrap(fn)
            obj.wait = wait
            return obj
        end
    }
)
